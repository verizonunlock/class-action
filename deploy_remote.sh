#!/bin/bash
# 🚀 DEPLOYMENT REMOTO - VERIZON CLASS ACTION
# Deploy desde MacBook local hacia servidor remoto

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 VERIZON CLASS ACTION - DEPLOYMENT REMOTO${NC}"
echo "=============================================="

# Configuración del servidor remoto
REMOTE_HOST=${REMOTE_HOST:-"your-server.com"}
REMOTE_USER=${REMOTE_USER:-"root"}
REMOTE_PATH="/opt/verizonunlock"
SSH_KEY=${SSH_KEY:-"~/.ssh/id_rsa"}

# Solicitar configuración si no está definida
if [[ "$REMOTE_HOST" == "your-server.com" ]]; then
    read -p "Servidor remoto (IP o dominio): " REMOTE_HOST
fi

if [[ "$REMOTE_USER" == "root" ]]; then
    read -p "Usuario SSH [$REMOTE_USER]: " input_user
    REMOTE_USER=${input_user:-$REMOTE_USER}
fi

echo -e "\n${YELLOW}📝 Configuración:${NC}"
echo "Servidor: $REMOTE_USER@$REMOTE_HOST"
echo "Ruta: $REMOTE_PATH"
echo "SSH Key: $SSH_KEY"

# Verificar conexión SSH
echo -e "\n${BLUE}🔐 Verificando conexión SSH...${NC}"
if ssh -i "$SSH_KEY" -o ConnectTimeout=10 "$REMOTE_USER@$REMOTE_HOST" "echo 'SSH OK'" 2>/dev/null; then
    echo -e "${GREEN}✅ Conexión SSH exitosa${NC}"
else
    echo -e "${RED}❌ Error: No se puede conectar via SSH${NC}"
    echo "Verifica:"
    echo "1. SSH key existe: $SSH_KEY"
    echo "2. Servidor accesible: $REMOTE_HOST"
    echo "3. Usuario correcto: $REMOTE_USER"
    exit 1
fi

# Crear directorio remoto si no existe
echo -e "${YELLOW}📁 Creando directorio remoto...${NC}"
ssh -i "$SSH_KEY" "$REMOTE_USER@$REMOTE_HOST" "mkdir -p $REMOTE_PATH"

# Función para sincronizar archivos
sync_files() {
    echo -e "${BLUE}📦 Sincronizando archivos...${NC}"
    
    # Excluir archivos innecesarios para producción
    rsync -avz --progress \
        --exclude='.git' \
        --exclude='node_modules' \
        --exclude='*.pyc' \
        --exclude='__pycache__' \
        --exclude='*.log' \
        --exclude='.DS_Store' \
        --exclude='exploit_*' \
        --exclude='*_destroyer*' \
        --exclude='*_exploit*' \
        --exclude='hardware_attack*' \
        --exclude='immediate_destruction*' \
        -e "ssh -i $SSH_KEY" \
        ./ "$REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/"
    
    echo -e "${GREEN}✅ Archivos sincronizados${NC}"
}

# Función para configurar docker en servidor remoto
setup_docker_remote() {
    echo -e "${YELLOW}🐳 Configurando Docker en servidor remoto...${NC}"
    
    ssh -i "$SSH_KEY" "$REMOTE_USER@$REMOTE_HOST" << 'EOF'
# Verificar si Docker está instalado
if ! command -v docker &> /dev/null; then
    echo "Instalando Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    systemctl enable docker
    systemctl start docker
else
    echo "Docker ya está instalado"
fi

# Verificar Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo "Instalando Docker Compose..."
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
else
    echo "Docker Compose ya está instalado"
fi
EOF
    
    echo -e "${GREEN}✅ Docker configurado en servidor remoto${NC}"
}

# Función para deploy de la aplicación
deploy_app() {
    echo -e "${BLUE}🚀 Desplegando aplicación...${NC}"
    
    ssh -i "$SSH_KEY" "$REMOTE_USER@$REMOTE_HOST" << EOF
cd $REMOTE_PATH

# Crear docker-compose.yml si no existe
if [[ ! -f "docker-compose.yml" ]]; then
    cat > docker-compose.yml << 'COMPOSE_EOF'
version: '3.8'

services:
  caddy:
    image: caddy:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile
      - caddy_data:/data
      - caddy_config:/config
      - ./static:/srv
    restart: unless-stopped

  api:
    build: ./api
    environment:
      - NODE_ENV=production
      - PORT=3000
      - SMTP_HOST=\${SMTP_HOST}
      - SMTP_USER=\${SMTP_USER}
      - SMTP_PASSWORD=\${SMTP_PASSWORD}
      - DOMAIN=\${DOMAIN}
    volumes:
      - ./data:/app/data
    restart: unless-stopped

  postgres:
    image: postgres:15-alpine
    environment:
      - POSTGRES_DB=verizonunlock
      - POSTGRES_USER=\${DB_USER:-postgres}
      - POSTGRES_PASSWORD=\${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    restart: unless-stopped

  redis:
    image: redis:alpine
    volumes:
      - redis_data:/data
    restart: unless-stopped

  email-worker:
    build: ./api
    command: node workers/email-worker.js
    environment:
      - NODE_ENV=production
      - SMTP_HOST=\${SMTP_HOST}
      - SMTP_USER=\${SMTP_USER}
      - SMTP_PASSWORD=\${SMTP_PASSWORD}
    depends_on:
      - redis
      - postgres
    restart: unless-stopped

volumes:
  caddy_data:
  caddy_config:
  postgres_data:
  redis_data:
COMPOSE_EOF
fi

# Crear Caddyfile si no existe
if [[ ! -f "Caddyfile" ]]; then
    cat > Caddyfile << 'CADDY_EOF'
\${DOMAIN} {
    root * /srv
    file_server
    
    handle_path /api/* {
        reverse_proxy api:3000
    }
    
    handle_path /admin* {
        root * /srv
        file_server
        
        @auth {
            path /admin*
        }
        basicauth @auth {
            admin \$2a\$14\$hashed_password_here
        }
    }
    
    # Security headers
    header {
        Strict-Transport-Security "max-age=31536000; includeSubDomains"
        X-Content-Type-Options "nosniff"
        X-Frame-Options "DENY"
        Referrer-Policy "no-referrer-when-downgrade"
    }
    
    # Gzip compression
    encode gzip
}

api.\${DOMAIN} {
    reverse_proxy api:3000
    
    header {
        Access-Control-Allow-Origin "https://\${DOMAIN}"
        Access-Control-Allow-Methods "GET, POST, OPTIONS"
        Access-Control-Allow-Headers "Content-Type, Authorization"
    }
}
CADDY_EOF
fi

# Crear directorio static y copiar archivos web
mkdir -p static data
cp *.html static/ 2>/dev/null || true
cp *.css static/ 2>/dev/null || true
cp *.js static/ 2>/dev/null || true

# Crear .env si no existe
if [[ ! -f ".env" ]]; then
    cat > .env << 'ENV_EOF'
# Configuración del servidor
DOMAIN=your-domain.com
SMTP_HOST=mail.your-domain.com
SMTP_USER=legal@your-domain.com
SMTP_PASSWORD=your-smtp-password
DB_PASSWORD=your-secure-db-password
EXPORT_SECRET=your-export-secret-token

# Para desarrollo
NODE_ENV=production
ENV_EOF
    
    echo "⚠️  IMPORTANTE: Edita el archivo .env con tus configuraciones reales"
fi

# Build y deploy con Docker Compose
echo "Construyendo y desplegando contenedores..."
docker-compose down 2>/dev/null || true
docker-compose up --build -d

echo "✅ Aplicación desplegada exitosamente"
docker-compose ps
EOF
    
    echo -e "${GREEN}✅ Aplicación desplegada${NC}"
}

# Función para crear script de sync de testing móvil
create_mobile_test_sync() {
    cat > sync_mobile_tests.sh << 'SYNC_EOF'
#!/bin/bash
# 🧪 SYNC DE TESTS MÓVILES DESDE MACBOOK AL SERVIDOR

REMOTE_HOST=$1
REMOTE_USER=${2:-root}
TEST_RESULTS_DIR="./mobile_test_results"
REMOTE_PATH="/opt/verizonunlock/test_results"

if [[ -z "$REMOTE_HOST" ]]; then
    echo "Usage: ./sync_mobile_tests.sh <server-host> [ssh-user]"
    exit 1
fi

echo "📱 Sincronizando resultados de tests móviles..."

# Crear directorio local si no existe
mkdir -p "$TEST_RESULTS_DIR"

# Función para ejecutar test y capturar resultados
run_mobile_test() {
    local device_id=$1
    local test_type=$2
    local output_file="$TEST_RESULTS_DIR/${device_id}_${test_type}_$(date +%Y%m%d_%H%M%S).json"
    
    echo "🔍 Ejecutando $test_type en dispositivo $device_id..."
    
    # Aquí irían los comandos de ADB/fastboot para testing
    # Por ahora creamos un placeholder con información del dispositivo
    cat > "$output_file" << EOF
{
    "device_id": "$device_id",
    "test_type": "$test_type", 
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "platform": "macos",
    "adb_devices": $(adb devices -l 2>/dev/null | tail -n +2 | head -n -1 | jq -R . | jq -s . || echo '[]'),
    "fastboot_devices": $(fastboot devices 2>/dev/null | jq -R . | jq -s . || echo '[]'),
    "system_info": {
        "os": "$(uname -s)",
        "version": "$(uname -r)",
        "arch": "$(uname -m)"
    },
    "test_results": {
        "connected": true,
        "unlockable": false,
        "carrier_lock": "verizon_locked",
        "bootloader_status": "locked"
    }
}
EOF
    
    echo "💾 Resultados guardados en: $output_file"
}

# Detectar dispositivos conectados
echo "📱 Detectando dispositivos móviles..."
if command -v adb &> /dev/null; then
    adb devices -l
    
    # Ejecutar tests en dispositivos detectados
    while read -r line; do
        if [[ $line == *"device"* ]]; then
            device_id=$(echo $line | awk '{print $1}')
            run_mobile_test "$device_id" "carrier_lock_test"
        fi
    done < <(adb devices | tail -n +2 | head -n -1)
else
    echo "⚠️  ADB no disponible. Instalando Android SDK..."
    # Instalación silenciosa para MacOS
    brew install --cask android-platform-tools 2>/dev/null || echo "Instalar manualmente: brew install --cask android-platform-tools"
fi

# Sincronizar resultados al servidor remoto
echo "📤 Sincronizando al servidor remoto..."
rsync -avz --progress \
    "$TEST_RESULTS_DIR/" \
    "$REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/"

echo "✅ Sincronización completa"
echo "🌐 Ver resultados en: https://your-domain.com/admin/test-results"
SYNC_EOF
    
    chmod +x sync_mobile_tests.sh
    echo -e "${GREEN}✅ Script de sync de tests móviles creado${NC}"
}

# Menú principal
echo -e "\n${YELLOW}🎯 Selecciona una acción:${NC}"
echo "1. Sincronizar archivos únicamente"
echo "2. Setup completo (Docker + Deploy)"  
echo "3. Solo configurar Docker"
echo "4. Solo deploy de aplicación"
echo "5. Crear scripts de testing móvil"
echo "6. Deploy completo (todo)"

read -p "Opción [1-6]: " option

case $option in
    1)
        sync_files
        ;;
    2)
        sync_files
        setup_docker_remote
        deploy_app
        ;;
    3)
        setup_docker_remote
        ;;
    4)
        deploy_app
        ;;
    5)
        create_mobile_test_sync
        ;;
    6)
        sync_files
        setup_docker_remote
        deploy_app
        create_mobile_test_sync
        ;;
    *)
        echo -e "${RED}❌ Opción inválida${NC}"
        exit 1
        ;;
esac

echo -e "\n${GREEN}🎉 DEPLOYMENT REMOTO COMPLETADO${NC}"
echo -e "${BLUE}📋 Próximos pasos:${NC}"
echo "1. Editar .env en el servidor con configuraciones reales"
echo "2. Configurar DNS para apuntar al servidor"
echo "3. Verificar certificados SSL"
echo "4. Para tests móviles: ./sync_mobile_tests.sh $REMOTE_HOST $REMOTE_USER"

echo -e "\n${YELLOW}🔧 Comandos útiles:${NC}"
echo "Ver logs: ssh $REMOTE_USER@$REMOTE_HOST 'cd $REMOTE_PATH && docker-compose logs -f'"
echo "Reiniciar: ssh $REMOTE_USER@$REMOTE_HOST 'cd $REMOTE_PATH && docker-compose restart'"
echo "Estado: ssh $REMOTE_USER@$REMOTE_HOST 'cd $REMOTE_PATH && docker-compose ps'"

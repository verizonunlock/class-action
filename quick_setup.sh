#!/bin/bash
# 🚀 QUICK SETUP - VERIZON CLASS ACTION
# Script de configuración rápida para MacBook -> Servidor remoto

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

clear
echo -e "${BLUE}"
cat << "EOF"
╔══════════════════════════════════════════╗
║    VERIZON CLASS ACTION - QUICK SETUP    ║
║     MacBook Development -> Remote Server ║  
╚══════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Configuración inicial
echo -e "${YELLOW}📝 CONFIGURACIÓN INICIAL:${NC}"
read -p "🏠 Servidor remoto (IP/dominio): " REMOTE_HOST
read -p "👤 Usuario SSH [$USER]: " REMOTE_USER
REMOTE_USER=${REMOTE_USER:-$USER}
read -p "🌐 Dominio del sitio: " DOMAIN
read -p "📧 Email para SSL: " ACME_EMAIL

# Validar inputs
if [[ -z "$REMOTE_HOST" || -z "$DOMAIN" || -z "$ACME_EMAIL" ]]; then
    echo -e "${RED}❌ Error: Todos los campos son requeridos${NC}"
    exit 1
fi

echo -e "\n${BLUE}📋 RESUMEN DE CONFIGURACIÓN:${NC}"
echo "Servidor: $REMOTE_USER@$REMOTE_HOST"
echo "Dominio: $DOMAIN"
echo "Email: $ACME_EMAIL"
echo "Path remoto: /opt/verizonunlock"

read -p "¿Continuar? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
fi

# === PASO 1: VERIFICAR DEPENDENCIAS LOCALES ===
echo -e "\n${YELLOW}🔧 PASO 1: Verificando dependencias locales...${NC}"

check_dependency() {
    if ! command -v $1 &> /dev/null; then
        echo -e "${RED}❌ $1 no encontrado${NC}"
        echo "Instalando $1..."
        case $1 in
            "adb")
                brew install --cask android-platform-tools
                ;;
            "jq")
                brew install jq
                ;;
            "rsync")
                echo "rsync debería estar incluido en macOS"
                ;;
            *)
                echo "Instala manualmente: $2"
                exit 1
                ;;
        esac
    else
        echo -e "${GREEN}✅ $1 OK${NC}"
    fi
}

# Verificar Homebrew primero
if ! command -v brew &> /dev/null; then
    echo -e "${YELLOW}🍺 Instalando Homebrew...${NC}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

check_dependency "adb" "brew install --cask android-platform-tools"
check_dependency "jq" "brew install jq"
check_dependency "rsync" "debería estar incluido"

# === PASO 2: CONFIGURAR SSH ===
echo -e "\n${YELLOW}🔐 PASO 2: Configurando acceso SSH...${NC}"

# Generar SSH key si no existe
SSH_KEY="$HOME/.ssh/id_rsa"
if [[ ! -f "$SSH_KEY" ]]; then
    echo "Generando SSH key..."
    ssh-keygen -t rsa -b 4096 -f "$SSH_KEY" -N ""
    echo -e "${GREEN}✅ SSH key generada: $SSH_KEY${NC}"
fi

# Test conexión SSH
echo "Probando conexión SSH..."
if ssh -i "$SSH_KEY" -o ConnectTimeout=5 "$REMOTE_USER@$REMOTE_HOST" "echo 'SSH OK'" 2>/dev/null; then
    echo -e "${GREEN}✅ Conexión SSH exitosa${NC}"
else
    echo -e "${YELLOW}⚠️  Conexión SSH falló. ¿Necesitas copiar la SSH key?${NC}"
    echo "Tu SSH key pública:"
    echo -e "${BLUE}$(cat ${SSH_KEY}.pub)${NC}"
    echo
    read -p "¿Continuar asumiendo que configurarás SSH después? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# === PASO 3: CREAR CONFIGURACIÓN ===
echo -e "\n${YELLOW}⚙️  PASO 3: Creando archivos de configuración...${NC}"

# Crear .env local para el deployment
cat > .env.deploy << EOF
REMOTE_HOST=$REMOTE_HOST
REMOTE_USER=$REMOTE_USER  
SSH_KEY=$SSH_KEY
DOMAIN=$DOMAIN
ACME_EMAIL=$ACME_EMAIL
EOF

echo -e "${GREEN}✅ .env.deploy creado${NC}"

# Crear script personalizado de deployment
cat > deploy_to_server.sh << EOF
#!/bin/bash
# Deploy personalizado generado por quick_setup.sh

export REMOTE_HOST="$REMOTE_HOST"
export REMOTE_USER="$REMOTE_USER" 
export SSH_KEY="$SSH_KEY"

./deploy_remote.sh
EOF

chmod +x deploy_to_server.sh
echo -e "${GREEN}✅ deploy_to_server.sh creado${NC}"

# Crear script personalizado de testing
cat > test_mobile_devices.sh << EOF
#!/bin/bash
# Mobile testing con sync automático

export REMOTE_HOST="$REMOTE_HOST"
export REMOTE_USER="$REMOTE_USER"
export SSH_KEY="$SSH_KEY"

./mobile_device_tester.sh
EOF

chmod +x test_mobile_devices.sh
echo -e "${GREEN}✅ test_mobile_devices.sh creado${NC}"

# === PASO 4: PREPARAR SERVIDOR REMOTO ===
echo -e "\n${YELLOW}🖥️  PASO 4: Preparando servidor remoto...${NC}"

# Crear directorio y configurar .env remoto
if ssh -i "$SSH_KEY" "$REMOTE_USER@$REMOTE_HOST" "mkdir -p /opt/verizonunlock" 2>/dev/null; then
    echo -e "${GREEN}✅ Directorio remoto creado${NC}"
    
    # Copiar template .env
    scp -i "$SSH_KEY" .env.remote.template "$REMOTE_USER@$REMOTE_HOST:/opt/verizonunlock/.env.template" 2>/dev/null && {
        echo -e "${GREEN}✅ Template .env copiado al servidor${NC}"
    } || {
        echo -e "${YELLOW}⚠️  No se pudo copiar .env template${NC}"
    }
else
    echo -e "${YELLOW}⚠️  No se pudo configurar el servidor remoto ahora${NC}"
fi

# === PASO 5: CREAR COMANDOS RÁPIDOS ===
echo -e "\n${YELLOW}⚡ PASO 5: Creando comandos rápidos...${NC}"

# Crear alias útiles
cat > aliases.sh << EOF
#!/bin/bash
# Aliases y comandos rápidos para el proyecto Verizon Class Action

# Deploy al servidor
alias verizon-deploy='./deploy_to_server.sh'

# Testing de dispositivos móviles  
alias verizon-test='./test_mobile_devices.sh'

# Logs del servidor remoto
alias verizon-logs='ssh -i $SSH_KEY $REMOTE_USER@$REMOTE_HOST "cd /opt/verizonunlock && docker-compose logs -f"'

# Status del servidor
alias verizon-status='ssh -i $SSH_KEY $REMOTE_USER@$REMOTE_HOST "cd /opt/verizonunlock && docker-compose ps"'

# Conectar al servidor
alias verizon-ssh='ssh -i $SSH_KEY $REMOTE_USER@$REMOTE_HOST'

# Sync resultados de tests
alias verizon-sync='./sync_mobile_tests.sh $REMOTE_HOST $REMOTE_USER'

echo "🚀 Aliases cargados para Verizon Class Action"
echo "Comandos disponibles:"
echo "  verizon-deploy  - Desplegar al servidor"
echo "  verizon-test    - Testing de dispositivos móviles"
echo "  verizon-logs    - Ver logs del servidor"
echo "  verizon-status  - Status de contenedores"
echo "  verizon-ssh     - Conectar al servidor"
echo "  verizon-sync    - Sincronizar tests móviles"
EOF

echo -e "${GREEN}✅ aliases.sh creado${NC}"

# === FINALIZACIÓN ===
echo -e "\n${GREEN}🎉 QUICK SETUP COMPLETADO${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

echo -e "\n${YELLOW}📋 PRÓXIMOS PASOS:${NC}"
echo "1. Cargar aliases: ${BLUE}source aliases.sh${NC}"
echo "2. Deploy inicial: ${BLUE}verizon-deploy${NC}"
echo "3. Configurar .env en el servidor:"
echo "   ${BLUE}verizon-ssh${NC}"
echo "   ${BLUE}cd /opt/verizonunlock && cp .env.template .env && nano .env${NC}"
echo "4. Testing de dispositivos: ${BLUE}verizon-test${NC}"

echo -e "\n${YELLOW}🔧 CONFIGURACIÓN DNS:${NC}"
echo "En Cloudflare o tu proveedor DNS:"
echo "A    @     [IP-del-servidor]"
echo "A    api   [IP-del-servidor]"
echo "A    mail  [IP-del-servidor]"

echo -e "\n${YELLOW}📱 USO DIARIO:${NC}"
echo "• Conecta dispositivos Pixel vía USB"
echo "• Ejecuta: ${BLUE}verizon-test${NC}"
echo "• Los resultados se sincronizan automáticamente"
echo "• Ver en: https://$DOMAIN/admin"

echo -e "\n${GREEN}💪 ¡LISTO PARA LA DEMANDA COLECTIVA CONTRA VERIZON!${NC}"

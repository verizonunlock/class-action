# 🚀 VERIZON CLASS ACTION - WORKFLOW SETUP

## MacBook Development → Remote Server Deployment

Este proyecto configura un flujo de trabajo completo para desarrollo local en MacBook y despliegue automático a un servidor remoto para la demanda colectiva contra Verizon por el bloqueo permanente de bootloaders en dispositivos Pixel.

---

## 🎯 INICIO RÁPIDO

### 1. Configuración Automática
```bash
./quick_setup.sh
```

Este script configurará:
- ✅ Dependencias locales (ADB, fastboot, jq)
- ✅ Acceso SSH al servidor remoto  
- ✅ Scripts de deployment personalizados
- ✅ Testing de dispositivos móviles
- ✅ Aliases útiles

### 2. Cargar Aliases
```bash
source aliases.sh
```

### 3. Deploy Inicial
```bash
verizon-deploy
```

---

## 📱 TESTING DE DISPOSITIVOS MÓVILES

### Conectar Dispositivos
1. Conecta dispositivos Pixel/Android vía USB
2. Habilita "USB Debugging" en Developer Options
3. Acepta la conexión ADB en el dispositivo

### Ejecutar Tests
```bash
verizon-test
```

**Qué hace este comando:**
- 🔍 Detecta dispositivos conectados (ADB + Fastboot)
- 📋 Extrae información detallada del dispositivo
- 🔒 Analiza el estado de carrier lock
- 💾 Guarda resultados en JSON
- 📤 Sincroniza automáticamente al servidor remoto

### Resultados
- **Local:** `./mobile_test_results/*.json`
- **Remoto:** `/opt/verizonunlock/test_results/*.json`
- **Web:** `https://tu-dominio.com/admin/test-results`

---

## 🖥️ GESTIÓN DEL SERVIDOR REMOTO

### Comandos Útiles
```bash
# Ver status de contenedores
verizon-status

# Ver logs en tiempo real
verizon-logs

# Conectar al servidor
verizon-ssh

# Sincronizar tests manualmente
verizon-sync
```

### Estructura del Servidor
```
/opt/verizonunlock/
├── docker-compose.yml     # Orquestación de contenedores
├── Caddyfile             # Configuración del proxy/SSL  
├── .env                  # Variables de entorno
├── static/               # Archivos web estáticos
├── api/                  # Backend Node.js
├── data/                 # Datos de la aplicación
├── logs/                 # Logs de todos los servicios
├── backups/              # Backups de base de datos
└── test_results/         # Resultados de tests móviles
```

---

## 🐳 SERVICIOS EN CONTENEDORES

El servidor remoto ejecuta los siguientes servicios:

| Servicio | Puerto | Descripción |
|----------|--------|-------------|
| **caddy** | 80, 443 | Reverse proxy, SSL automático |
| **api** | 3000 | Backend Node.js para registros |
| **postgres** | 5432 | Base de datos principal |
| **redis** | 6379 | Cache y colas de trabajo |
| **email-worker** | - | Procesador de emails |
| **analytics-worker** | - | Análisis de datos |
| **test-processor** | - | Procesador de resultados de tests |
| **prometheus** | 9090 | Métricas y monitoring |
| **grafana** | 3001 | Dashboard de métricas |

---

## 📊 MONITOREO Y ANALYTICS

### Dashboard Principal
- **URL:** `https://tu-dominio.com/admin`
- **Métricas:** `https://tu-dominio.com:3001` (Grafana)
- **API Health:** `https://api.tu-dominio.com/health`

### Métricas Importantes
- 📊 Registros de demandantes por día
- 🔒 Dispositivos con carrier lock detectados
- 📧 Emails enviados y confirmaciones
- 🌐 Tráfico web y conversiones
- 💾 Salud de la base de datos

---

## 🔧 CONFIGURACIÓN AVANZADA

### Variables de Entorno (.env)
```bash
# En el servidor remoto
verizon-ssh
cd /opt/verizonunlock
nano .env
```

**Variables críticas:**
- `DOMAIN`: Tu dominio principal
- `SMTP_*`: Configuración de email
- `DB_PASSWORD`: Password de PostgreSQL
- `JWT_SECRET`: Clave para tokens
- `ADMIN_PASSWORD`: Password del admin

### Configuración DNS
En Cloudflare o tu proveedor:
```
A    @     [IP-del-servidor]
A    api   [IP-del-servidor]  
A    mail  [IP-del-servidor]
CNAME www  tu-dominio.com
```

### SSL/HTTPS
Caddy maneja automáticamente:
- ✅ Certificados SSL de Let's Encrypt
- ✅ Renovación automática
- ✅ Redirección HTTP → HTTPS
- ✅ Security headers

---

## 🛠️ DEVELOPMENT WORKFLOW

### Desarrollo Local (MacBook)
```bash
# Editar archivos localmente
code .

# Testing con dispositivos físicos  
verizon-test

# Deploy a servidor remoto
verizon-deploy
```

### Estructura de Archivos
```
.
├── quick_setup.sh           # Setup inicial automatizado
├── deploy_remote.sh         # Deploy al servidor remoto
├── mobile_device_tester.sh  # Testing de dispositivos  
├── docker-compose.remote.yml # Configuración de contenedores
├── .env.remote.template     # Template de variables
├── api/                     # Backend Node.js
│   ├── server.js
│   ├── package.json
│   └── workers/
├── static/                  # Frontend HTML/CSS/JS
│   ├── index.html
│   ├── admin_dashboard.html
│   └── assets/
└── mobile_test_results/     # Resultados locales
```

---

## 📱 INTEGRACIÓN CON DISPOSITIVOS

### Dispositivos Soportados
- ✅ Google Pixel (todas las generaciones)
- ✅ Samsung Galaxy
- ✅ OnePlus, LG, HTC, Motorola
- ✅ Cualquier Android con ADB

### Modes de Conexión
- **ADB Mode:** Para extracción de datos del sistema
- **Fastboot Mode:** Para análisis del bootloader
- **Recovery Mode:** Para tests avanzados

### Datos Extraídos
- 📋 Información del dispositivo (modelo, versión, etc.)
- 🔒 Estado del bootloader (locked/unlocked)  
- 📡 Información del carrier
- ⚙️ Configuraciones OEM
- 🛡️ Políticas de seguridad

---

## 🎯 OBJETIVOS DE LA DEMANDA

### Argumentos Legales
- **Sherman Antitrust Act:** Monopolio anticompetitivo
- **Consumer Protection Laws:** Publicidad engañosa
- **Deceptive Trade Practices:** Limitaciones no divulgadas

### Daños Estimados
- **$850+ por dispositivo afectado**
- **Millones de usuarios impactados**
- **Pérdida de valor del dispositivo**
- **Costos de oportunidad**

### Evidence Collection
Cada test de dispositivo genera evidencia forense:
- 📄 Logs técnicos detallados
- 🔒 Pruebas de carrier lock
- 📊 Patrones de bloqueo sistemático
- 💾 Metadatos timestamped

---

## 🚨 CONSIDERACIONES DE SEGURIDAD

### Datos Sensibles
- ❌ No almacenar información personal
- ✅ Solo metadatos técnicos
- ✅ Hashing de device IDs
- ✅ Encriptación en tránsito

### Compliance
- 📋 GDPR compliance para usuarios EU
- 🇺🇸 CCPA compliance para California
- 🔒 SOX compliance para records financieros
- ⚖️ Legal hold para litigation

---

## 📞 SOPORTE Y DOCUMENTACIÓN

### Recursos
- **Website:** https://verizonunlock.org
- **Legal Team:** legal@verizonunlock.org
- **Support:** register@verizonunlock.org
- **Tech Issues:** admin@verizonunlock.org

### Status del Proyecto
- 🟢 **Active Development**
- ⚖️ **Legal Phase:** Evidence Collection
- 👥 **Current Registrations:** Ver dashboard
- 📈 **Growth Rate:** Ver analytics

---

## ⚡ COMANDOS DE EMERGENCIA

### Si el servidor se cae:
```bash
verizon-ssh
cd /opt/verizonunlock
docker-compose restart
```

### Si hay problemas con tests:
```bash
# Resetear ADB
adb kill-server && adb start-server

# Re-ejecutar tests
verizon-test
```

### Backup completo:
```bash
verizon-ssh
cd /opt/verizonunlock
./scripts/backup.sh
```

---

**¡LISTO PARA TOMAR ACCIÓN LEGAL CONTRA VERIZON! 💪⚖️**

#!/bin/bash
# 📱 VERIZON DEVICE TESTING - MACOS
# Script para testing de dispositivos USB en MacBook y sync al servidor

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}📱 VERIZON DEVICE TESTING - MACOS${NC}"
echo "===================================="

# Configuración
TEST_RESULTS_DIR="./mobile_test_results"
REMOTE_HOST=${REMOTE_HOST:-""}
REMOTE_USER=${REMOTE_USER:-"root"}
REMOTE_PATH="/opt/verizonunlock/test_results"
SSH_KEY=${SSH_KEY:-"~/.ssh/id_rsa"}

# Crear directorio de resultados
mkdir -p "$TEST_RESULTS_DIR"

# Verificar dependencias para MacOS
check_macos_dependencies() {
    echo -e "${YELLOW}🔧 Verificando dependencias en MacOS...${NC}"
    
    # Verificar Homebrew
    if ! command -v brew &> /dev/null; then
        echo -e "${RED}❌ Homebrew no encontrado${NC}"
        echo "Instalar con: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        exit 1
    fi
    echo -e "${GREEN}✅ Homebrew OK${NC}"
    
    # Verificar Android Platform Tools
    if ! command -v adb &> /dev/null; then
        echo -e "${YELLOW}📱 Instalando Android Platform Tools...${NC}"
        brew install --cask android-platform-tools
    fi
    echo -e "${GREEN}✅ ADB/Fastboot OK${NC}"
    
    # Verificar USB debugging tools
    if ! command -v system_profiler &> /dev/null; then
        echo -e "${RED}❌ system_profiler no encontrado (parte de macOS)${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ USB tools OK${NC}"
    
    # Verificar jq para JSON processing
    if ! command -v jq &> /dev/null; then
        echo -e "${YELLOW}📄 Instalando jq...${NC}"
        brew install jq
    fi
    echo -e "${GREEN}✅ JSON tools OK${NC}"
}

# Función para detectar dispositivos USB
detect_usb_devices() {
    echo -e "${BLUE}🔍 Detectando dispositivos USB...${NC}"
    
    # Usar system_profiler para obtener info detallada de USB
    local usb_info=$(system_profiler SPUSBDataType -json 2>/dev/null)
    
    # Detectar dispositivos Android/Pixel
    local android_devices=$(echo "$usb_info" | jq -r '
        .SPUSBDataType[]? | 
        recurse(.items[]?) | 
        select(.vendor_name? | test("Google|Samsung|LG|HTC|Motorola|OnePlus"; "i")) |
        {
            device_name: .name,
            vendor: .vendor_name,
            product_id: .product_id,
            vendor_id: .vendor_id,
            serial: .serial_num
        }' 2>/dev/null || echo '[]')
    
    echo "$android_devices"
}

# Función para obtener info detallada del dispositivo
get_device_info() {
    local device_id=$1
    local output_file="$TEST_RESULTS_DIR/${device_id}_device_info_$(date +%Y%m%d_%H%M%S).json"
    
    echo -e "${BLUE}📋 Obteniendo información del dispositivo $device_id...${NC}"
    
    # Info básica del dispositivo vía ADB
    local device_info='{}'
    
    if adb -s "$device_id" get-state &>/dev/null; then
        device_info=$(cat << EOF
{
    "device_id": "$device_id",
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "platform": "macos",
    "connection_type": "adb",
    "properties": {
        "manufacturer": "$(adb -s "$device_id" shell getprop ro.product.manufacturer 2>/dev/null | tr -d '\r')",
        "model": "$(adb -s "$device_id" shell getprop ro.product.model 2>/dev/null | tr -d '\r')",
        "device": "$(adb -s "$device_id" shell getprop ro.product.device 2>/dev/null | tr -d '\r')",
        "brand": "$(adb -s "$device_id" shell getprop ro.product.brand 2>/dev/null | tr -d '\r')",
        "android_version": "$(adb -s "$device_id" shell getprop ro.build.version.release 2>/dev/null | tr -d '\r')",
        "api_level": "$(adb -s "$device_id" shell getprop ro.build.version.sdk 2>/dev/null | tr -d '\r')",
        "build_id": "$(adb -s "$device_id" shell getprop ro.build.id 2>/dev/null | tr -d '\r')",
        "security_patch": "$(adb -s "$device_id" shell getprop ro.build.version.security_patch 2>/dev/null | tr -d '\r')",
        "bootloader": "$(adb -s "$device_id" shell getprop ro.bootloader 2>/dev/null | tr -d '\r')",
        "hardware": "$(adb -s "$device_id" shell getprop ro.hardware 2>/dev/null | tr -d '\r')"
    },
    "carrier_info": {
        "operator_name": "$(adb -s "$device_id" shell getprop gsm.sim.operator.alpha 2>/dev/null | tr -d '\r')",
        "operator_numeric": "$(adb -s "$device_id" shell getprop gsm.sim.operator.numeric 2>/dev/null | tr -d '\r')",
        "network_type": "$(adb -s "$device_id" shell getprop gsm.network.type 2>/dev/null | tr -d '\r')"
    }
}
EOF
        )
    else
        # Si no hay conexión ADB, usar fastboot
        if fastboot devices | grep -q "$device_id"; then
            device_info=$(cat << EOF
{
    "device_id": "$device_id",
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "platform": "macos",
    "connection_type": "fastboot",
    "bootloader_info": {
        "unlocked": "$(fastboot -s "$device_id" oem device-info 2>&1 | grep -i unlock | head -1 || echo 'unknown')",
        "device_state": "$(fastboot -s "$device_id" getvar device-state 2>&1 | grep device-state | cut -d: -f2 | tr -d ' ' || echo 'unknown')",
        "version": "$(fastboot -s "$device_id" getvar version 2>&1 | grep version | head -1 | cut -d: -f2 | tr -d ' ' || echo 'unknown')"
    }
}
EOF
            )
        else
            device_info=$(cat << EOF
{
    "device_id": "$device_id",
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "platform": "macos",
    "connection_type": "none",
    "error": "No ADB or Fastboot connection available"
}
EOF
            )
        fi
    fi
    
    echo "$device_info" | jq . > "$output_file"
    echo -e "${GREEN}💾 Info guardada: $output_file${NC}"
    
    return 0
}

# Función para test de carrier lock
test_carrier_lock() {
    local device_id=$1
    local output_file="$TEST_RESULTS_DIR/${device_id}_carrier_test_$(date +%Y%m%d_%H%M%S).json"
    
    echo -e "${BLUE}🔒 Testing carrier lock en $device_id...${NC}"
    
    local test_results='{}'
    
    if adb -s "$device_id" get-state &>/dev/null; then
        # Test con comandos específicos para carrier lock
        test_results=$(cat << EOF
{
    "device_id": "$device_id",
    "test_type": "carrier_lock_analysis",
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "platform": "macos",
    "tests": {
        "sim_lock_status": "$(adb -s "$device_id" shell getprop ro.telephony.call_ring.multiple 2>/dev/null || echo 'unknown')",
        "carrier_config": "$(adb -s "$device_id" shell dumpsys telephony.registry | grep -i carrier | head -3 2>/dev/null || echo 'access_denied')",
        "network_locked": "$(adb -s "$device_id" shell getprop gsm.sim.state 2>/dev/null | tr -d '\r')",
        "bootloader_unlock_status": "$(adb -s "$device_id" shell getprop ro.oem_unlock_supported 2>/dev/null | tr -d '\r')",
        "developer_options": "$(adb -s "$device_id" shell settings get global development_settings_enabled 2>/dev/null | tr -d '\r')",
        "usb_debugging": "$(adb -s "$device_id" shell settings get global adb_enabled 2>/dev/null | tr -d '\r')"
    },
    "verizon_specific": {
        "carrier_policy": "$(adb -s "$device_id" shell dumpsys device_policy | grep -i verizon 2>/dev/null || echo 'not_found')",
        "oem_unlock_allowed": "$(adb -s "$device_id" shell settings get global oem_unlock_allowed 2>/dev/null | tr -d '\r')",
        "carrier_provisioning": "$(adb -s "$device_id" shell dumpsys telephony.registry | grep -i provisioning 2>/dev/null || echo 'access_denied')"
    },
    "analysis": {
        "probably_verizon_locked": false,
        "bootloader_unlockable": false,
        "evidence_found": [],
        "recommended_action": "requires_physical_inspection"
    }
}
EOF
        )
        
        # Análisis básico
        local oem_unlock_allowed=$(echo "$test_results" | jq -r '.verizon_specific.oem_unlock_allowed')
        local oem_unlock_supported=$(echo "$test_results" | jq -r '.tests.bootloader_unlock_status')
        
        if [[ "$oem_unlock_allowed" == "0" ]] || [[ "$oem_unlock_supported" == "false" ]]; then
            test_results=$(echo "$test_results" | jq '.analysis.probably_verizon_locked = true')
            test_results=$(echo "$test_results" | jq '.analysis.evidence_found += ["oem_unlock_disabled"]')
        fi
        
    else
        test_results=$(cat << EOF
{
    "device_id": "$device_id",
    "test_type": "carrier_lock_analysis",
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "platform": "macos", 
    "error": "No ADB connection - device may be locked or in fastboot mode",
    "recommended_action": "connect_via_fastboot_for_bootloader_analysis"
}
EOF
        )
    fi
    
    echo "$test_results" | jq . > "$output_file"
    echo -e "${GREEN}💾 Test results: $output_file${NC}"
    
    return 0
}

# Función para sync remoto
sync_to_remote() {
    if [[ -z "$REMOTE_HOST" ]]; then
        read -p "Servidor remoto (opcional): " REMOTE_HOST
    fi
    
    if [[ -n "$REMOTE_HOST" ]]; then
        echo -e "${BLUE}📤 Sincronizando resultados al servidor remoto...${NC}"
        
        # Crear directorio remoto si no existe
        ssh -i "$SSH_KEY" "$REMOTE_USER@$REMOTE_HOST" "mkdir -p $REMOTE_PATH" 2>/dev/null || true
        
        # Sincronizar archivos
        rsync -avz --progress \
            "$TEST_RESULTS_DIR/" \
            "$REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/" 2>/dev/null || {
            echo -e "${YELLOW}⚠️  No se pudo sincronizar. Verifica conexión SSH.${NC}"
            return 1
        }
        
        echo -e "${GREEN}✅ Resultados sincronizados${NC}"
        echo -e "${BLUE}🌐 Ver en: https://your-domain.com/admin/test-results${NC}"
    fi
}

# Función principal de testing
run_device_tests() {
    echo -e "${YELLOW}🧪 Iniciando tests de dispositivos...${NC}"
    
    # Lista de dispositivos ADB
    echo -e "${BLUE}📱 Dispositivos ADB detectados:${NC}"
    adb devices -l
    
    # Lista de dispositivos Fastboot  
    echo -e "${BLUE}⚡ Dispositivos Fastboot detectados:${NC}"
    fastboot devices
    
    # Test cada dispositivo ADB
    while read -r line; do
        if [[ $line == *"device"* ]]; then
            device_id=$(echo $line | awk '{print $1}')
            if [[ -n "$device_id" ]]; then
                echo -e "${YELLOW}🔍 Testing device: $device_id${NC}"
                get_device_info "$device_id"
                test_carrier_lock "$device_id"
            fi
        fi
    done < <(adb devices | tail -n +2 | head -n -1)
    
    # Test cada dispositivo Fastboot
    while read -r line; do
        if [[ -n "$line" ]]; then
            device_id=$(echo $line | awk '{print $1}')
            if [[ -n "$device_id" ]]; then
                echo -e "${YELLOW}⚡ Testing fastboot device: $device_id${NC}"
                get_device_info "$device_id"
            fi
        fi
    done < <(fastboot devices)
    
    echo -e "${GREEN}✅ Tests completados${NC}"
    echo -e "${BLUE}📁 Resultados en: $TEST_RESULTS_DIR${NC}"
    
    # Mostrar resumen
    echo -e "\n${YELLOW}📊 RESUMEN DE TESTS:${NC}"
    find "$TEST_RESULTS_DIR" -name "*.json" -exec echo "📄 {}" \; | tail -10
}

# Menú principal
echo -e "\n${YELLOW}🎯 Opciones de testing:${NC}"
echo "1. Verificar dependencias MacOS"
echo "2. Detectar dispositivos USB"
echo "3. Ejecutar tests completos"
echo "4. Solo info de dispositivos"
echo "5. Solo test de carrier lock"
echo "6. Sincronizar resultados al servidor"
echo "7. Todo (tests + sync)"

read -p "Opción [1-7]: " option

case $option in
    1)
        check_macos_dependencies
        ;;
    2)
        detect_usb_devices | jq .
        ;;
    3)
        check_macos_dependencies
        run_device_tests
        ;;
    4)
        adb devices -l
        fastboot devices
        ;;
    5)
        while read -r line; do
            if [[ $line == *"device"* ]]; then
                device_id=$(echo $line | awk '{print $1}')
                [[ -n "$device_id" ]] && test_carrier_lock "$device_id"
            fi
        done < <(adb devices | tail -n +2 | head -n -1)
        ;;
    6)
        sync_to_remote
        ;;
    7)
        check_macos_dependencies
        run_device_tests
        sync_to_remote
        ;;
    *)
        echo -e "${RED}❌ Opción inválida${NC}"
        exit 1
        ;;
esac

echo -e "\n${GREEN}🎯 TESTING COMPLETADO${NC}"
echo -e "${BLUE}💡 Próximos pasos:${NC}"
echo "- Conecta dispositivos Pixel/Android vía USB"
echo "- Habilita USB Debugging en Developer Options" 
echo "- Ejecuta tests regulares para monitorear carrier locks"
echo "- Resultados se sincronizan automáticamente al servidor"

#!/bin/bash
# 🚀 SETUP GITHUB REPOSITORY - VERIZON CLASS ACTION

echo -e "\033[34m"
cat << "EOF"
╔════════════════════════════════════════╗
║     VERIZON CLASS ACTION - GITHUB      ║
║      Repository Setup Automation      ║
╚════════════════════════════════════════╝
EOF
echo -e "\033[0m"

# Solicitar información del usuario
read -p "🏠 Tu usuario de GitHub: " GITHUB_USER
read -p "📦 Nombre del repositorio [verizon-class-action]: " REPO_NAME
REPO_NAME=${REPO_NAME:-verizon-class-action}

# Validar
if [[ -z "$GITHUB_USER" ]]; then
    echo "❌ Error: Usuario de GitHub requerido"
    exit 1
fi

echo -e "\n\033[33m📋 CONFIGURACIÓN:\033[0m"
echo "Usuario: $GITHUB_USER"
echo "Repositorio: $REPO_NAME"
echo "URL: https://github.com/$GITHUB_USER/$REPO_NAME"

read -p "¿Continuar? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
fi

# Verificar si ya existe remote
if git remote get-url origin 2>/dev/null; then
    echo "🔄 Remote origin ya existe, actualizando..."
    git remote set-url origin "https://github.com/$GITHUB_USER/$REPO_NAME.git"
else
    echo "🔗 Agregando remote origin..."
    git remote add origin "https://github.com/$GITHUB_USER/$REPO_NAME.git"
fi

# Asegurar rama main
echo "🌿 Configurando rama main..."
git branch -M main

# Mostrar instrucciones
echo -e "\n\033[32m✅ REPOSITORIO CONFIGURADO LOCALMENTE\033[0m"
echo -e "\033[31m"
echo "IMPORTANTE: Antes de hacer push, crea el repositorio en GitHub:"
echo "1. Ve a: https://github.com/new"
echo "2. Repository name: $REPO_NAME"
echo "3. Description: Legal evidence collection for class action against Verizon carrier lock practices"  
echo "4. ✅ Public (para máxima visibilidad legal)"
echo "5. ❌ NO inicializar con README/LICENSE/gitignore"
echo "6. Click 'Create repository'"
echo -e "\033[0m"

read -p "Presiona ENTER cuando hayas creado el repositorio en GitHub..."

# Hacer el push
echo -e "\n🚀 Subiendo código a GitHub..."
if git push -u origin main; then
    echo -e "\n\033[32m🎉 ¡ÉXITO! Repositorio subido a GitHub\033[0m"
    echo -e "\033[34m🌐 Ver en: https://github.com/$GITHUB_USER/$REPO_NAME\033[0m"
    
    echo -e "\n\033[33m📢 PRÓXIMOS PASOS:\033[0m"
    echo "1. Configurar GitHub Pages (si deseas hosting web)"
    echo "2. Configurar GitHub Secrets para CI/CD"
    echo "3. Invitar colaboradores al proyecto"
    echo "4. Crear issues para tareas pendientes"
    echo "5. Configurar webhooks para deployment automático"
    
    echo -e "\n\033[33m💪 ACCIONES RECOMENDADAS:\033[0m"
    echo "• Compartir en redes sociales: #VerizonClassAction"
    echo "• Contactar medios especializados en tech/legal"
    echo "• Documentar casos de usuarios afectados"
    echo "• Crear PRs para mejoras al platform"
    
else
    echo -e "\n\033[31m❌ Error al subir. Verifica:\033[0m"
    echo "1. Repositorio creado en GitHub"
    echo "2. Permisos de acceso correctos"
    echo "3. Conexión a internet estable"
    echo "4. Token de GitHub configurado (si usas 2FA)"
fi

echo -e "\n\033[36m⚖️ RECUERDA: Este proyecto es para recolección legal de evidencia."
echo "NO proporciona servicios de desbloqueo ni exploits.\033[0m"
echo -e "\n\033[32m¡LISTO PARA LA DEMANDA COLECTIVA CONTRA VERIZON! 💪⚖️\033[0m"

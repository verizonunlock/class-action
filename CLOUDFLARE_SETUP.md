# 🚀 CONFIGURACIÓN CLOUDFLARE + DEPLOYMENT
## Complete Cloudflare DNS & Deployment Setup

### 📋 REQUISITOS PREVIOS
- ✅ Dominio comprado y transferido a Cloudflare Registrar
- ✅ Mail server configurado
- ✅ Cuenta GitHub para hosting

---

## 🌐 CONFIGURACIÓN DNS EN CLOUDFLARE

### 1. Acceder al Dashboard de Cloudflare
1. Ir a `https://dash.cloudflare.com`
2. Seleccionar tu dominio
3. Ir a la pestaña **DNS > Records**

### 2. Configurar Registros DNS

#### Para GitHub Pages:
```
Type: CNAME
Name: www
Content: [tu-usuario].github.io
Proxy: ✅ Proxied (naranja)

Type: A  
Name: @
Content: 185.199.108.153
Proxy: ✅ Proxied (naranja)

Type: A
Name: @
Content: 185.199.109.153
Proxy: ✅ Proxied (naranja)

Type: A
Name: @
Content: 185.199.110.153
Proxy: ✅ Proxied (naranja)

Type: A
Name: @
Content: 185.199.111.153
Proxy: ✅ Proxied (naranja)
```

#### Para API Backend (Netlify/Railway):
```
Type: CNAME
Name: api
Content: [tu-app].netlify.app
Proxy: ✅ Proxied (naranja)
```

#### Para Email:
```
Type: MX
Name: @
Content: mail.[tu-dominio].org
Priority: 10
Proxy: ❌ DNS only (gris)

Type: A
Name: mail
Content: [IP-de-tu-mail-server]
Proxy: ❌ DNS only (gris)
```

---

## 🔒 CONFIGURACIÓN SSL/TLS

### 1. Configurar SSL en Cloudflare
1. Ir a **SSL/TLS > Overview**
2. Seleccionar: **Full (strict)**
3. Activar **Always Use HTTPS**

### 2. Configurar Edge Certificates
1. Ir a **SSL/TLS > Edge Certificates**
2. Activar **Automatic HTTPS Rewrites**
3. Activar **Certificate Transparency Monitoring**

---

## 📁 DEPLOYMENT EN GITHUB PAGES

### 1. Crear Repositorio GitHub
```bash
# En tu terminal local:
cd /tmp/unlock_payload
git init
git add .
git commit -m "Initial commit: Verizon Class Action site"

# Crear repo en GitHub y conectar:
git remote add origin https://github.com/[tu-usuario]/verizon-class-action.git
git branch -M main
git push -u origin main
```

### 2. Configurar GitHub Pages
1. Ir a tu repositorio en GitHub
2. **Settings > Pages**
3. **Source**: Deploy from a branch
4. **Branch**: main
5. **Folder**: / (root)
6. **Custom domain**: [tu-dominio].org
7. ✅ **Enforce HTTPS**

### 3. Verificar Deployment
- Esperar 5-10 minutos
- Verificar en: `https://[tu-dominio].org`

---

## 🖥️ DEPLOYMENT BACKEND API

### Opción 1: Railway (Recomendado)
```bash
# Instalar Railway CLI:
npm install -g @railway/cli

# Login y deploy:
cd /tmp/unlock_payload/api
railway login
railway new
railway link
railway up
```

### Opción 2: Netlify Functions
```bash
# Crear netlify.toml:
cd /tmp/unlock_payload
cat > netlify.toml << 'EOF'
[build]
  command = "cd api && npm install"
  functions = "api"

[build.environment]
  NODE_VERSION = "18"

[[redirects]]
  from = "/api/*"
  to = "/.netlify/functions/:splat"
  status = 200
EOF
```

### 3. Variables de Entorno
Configurar en tu plataforma de hosting:
```env
SMTP_HOST=mail.[tu-dominio].org
SMTP_USER=legal@[tu-dominio].org
SMTP_PASSWORD=[tu-password-email]
DOMAIN=[tu-dominio].org
EXPORT_SECRET=[genera-un-token-secreto]
NODE_ENV=production
```

---

## ✉️ CONFIGURACIÓN EMAIL AVANZADA

### 1. Configurar DKIM/SPF en Cloudflare
```
Type: TXT
Name: @
Content: "v=spf1 include:_spf.google.com include:[tu-mail-server] ~all"

Type: TXT  
Name: _dmarc
Content: "v=DMARC1; p=quarantine; rua=mailto:dmarc@[tu-dominio].org"

Type: TXT
Name: [selector]._domainkey
Content: [tu-dkim-key]
```

### 2. Crear Aliases de Email
En tu panel de mail server:
- `legal@[dominio].org` → Email principal
- `register@[dominio].org` → Registros
- `updates@[dominio].org` → Notificaciones
- `evidence@[dominio].org` → Evidencia legal

---

## 🛡️ CONFIGURACIONES DE SEGURIDAD

### 1. Cloudflare Security
1. **Security > WAF**: Activar reglas básicas
2. **Security > Bot Fight Mode**: Activar
3. **Security > Rate Limiting**: 100 requests/min por IP

### 2. Headers de Seguridad
Agregar en **Rules > Transform Rules**:
```
Content-Security-Policy: default-src 'self'; script-src 'self' 'unsafe-inline'
X-Frame-Options: DENY
X-Content-Type-Options: nosniff
Referrer-Policy: strict-origin-when-cross-origin
```

---

## 📊 CONFIGURACIÓN DE ANALYTICS

### Cloudflare Analytics
1. **Analytics > Web Analytics**: Activar
2. Agregar snippet al HTML (opcional)

### Google Analytics (Opcional)
```html
<!-- Agregar antes de </head> en index.html -->
<script async src="https://www.googletagmanager.com/gtag/js?id=G-XXXXXXXXXX"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'G-XXXXXXXXXX');
</script>
```

---

## ⚡ OPTIMIZACIONES DE RENDIMIENTO

### 1. Cloudflare Performance
1. **Speed > Optimization**: Activar Auto Minify (CSS, JS, HTML)
2. **Speed > Optimization**: Activar Rocket Loader
3. **Caching > Configuration**: Cache Level = Standard

### 2. Compresión
```
Type: TXT
Name: @  
Content: Auto Minify activado en Cloudflare
```

---

## 🧪 TESTING Y VERIFICACIÓN

### 1. Verificar DNS
```bash
# Verificar propagación DNS:
dig [tu-dominio].org
dig www.[tu-dominio].org  
dig api.[tu-dominio].org
dig mail.[tu-dominio].org

# Verificar MX records:
dig MX [tu-dominio].org
```

### 2. Verificar SSL
```bash
# Test SSL:
curl -I https://[tu-dominio].org
openssl s_client -connect [tu-dominio].org:443 -servername [tu-dominio].org
```

### 3. Verificar Email
```bash
# Test SMTP:
telnet mail.[tu-dominio].org 587
```

---

## 📱 CONFIGURACIÓN MOBILE-FIRST

### 1. PWA Configuration
Crear `manifest.json`:
```json
{
  "name": "Verizon Class Action",
  "short_name": "VZ Unlock",
  "description": "Join the fight against Verizon carrier locks",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#1e40af",
  "theme_color": "#1e40af",
  "icons": [
    {
      "src": "/icon-192.png",
      "sizes": "192x192",
      "type": "image/png"
    }
  ]
}
```

---

## 🚀 COMANDOS DE DEPLOYMENT RÁPIDO

### Setup Completo en 5 Minutos:
```bash
# 1. Preparar archivos
cd /tmp/unlock_payload
git init
git add .
git commit -m "Verizon Class Action - Ready for deployment"

# 2. Deploy a GitHub
git remote add origin https://github.com/[usuario]/verizon-unlock.git
git push -u origin main

# 3. Deploy API a Railway
cd api
npm install
railway login
railway new verizon-api
railway up

# 4. Verificar todo
curl https://[tu-dominio].org
curl https://api.[tu-dominio].org/api/health
```

---

## 📞 PRÓXIMOS PASOS INMEDIATOS

1. **¿Cuál es tu dominio exacto?** (para actualizar configuraciones)
2. **¿Tienes GitHub configurado?** (para deployment)
3. **¿Preferes Railway o Netlify para API?** 
4. **¿Configuramos DNS ahora mismo?**

Todo está listo para deployment en **menos de 10 minutos** una vez que tengas los datos específicos de tu dominio y preferencias de hosting. 🎯

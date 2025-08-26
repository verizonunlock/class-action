# ⚖️ Verizon Class Action - Carrier Lock Evidence Collection

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Platform](https://img.shields.io/badge/platform-macOS-lightgrey.svg)
![Legal](https://img.shields.io/badge/legal-class%20action-red.svg)

> **Legal evidence collection system targeting Verizon's anticompetitive practice of permanently locking Pixel device bootloaders**

---

## 🎯 **PROJECT OVERVIEW**

This project provides a complete workflow for collecting forensic evidence of Verizon's systematic carrier locking practices on Google Pixel devices, supporting a class action lawsuit under:

- **Sherman Antitrust Act** - Anticompetitive monopoly practices  
- **Consumer Protection Laws** - Deceptive advertising
- **State Deceptive Trade Practices** - Undisclosed limitations

**Estimated damages: $850+ per affected device**

---

## 🚀 **QUICK START**

### 1. Automated Setup
```bash
git clone https://github.com/your-username/verizon-class-action.git
cd verizon-class-action
./quick_setup.sh
```

### 2. Load Aliases
```bash
source aliases.sh
```

### 3. Deploy to Server
```bash
verizon-deploy
```

### 4. Test Devices
```bash
verizon-test
```

---

## 📱 **DEVICE TESTING**

### Supported Devices
- ✅ Google Pixel (all generations with Tensor G4+)
- ✅ Samsung Galaxy, OnePlus, LG, HTC, Motorola
- ✅ Any Android device with ADB/Fastboot support

### What We Collect
- 🔍 **Bootloader status** (locked/unlocked capability)
- 📡 **Carrier configuration** and restrictions
- ⚙️ **OEM unlock settings** and policies
- 🛡️ **Device security** configurations
- 📊 **Systematic locking patterns**

### Legal Compliance
- ❌ **NO personal data** collection
- ✅ **Technical metadata only**
- ✅ **Anonymized device IDs**
- ✅ **GDPR/CCPA compliant**

---

## 🏗️ **ARCHITECTURE**

### Local Development (macOS)
```
MacBook Pro
├── 📱 USB Device Testing
├── 🔍 ADB/Fastboot Analysis  
├── 💾 Local Evidence Storage
└── 📤 Auto-sync to Server
```

### Remote Server
```
Production Server
├── 🌐 Web Registration Portal
├── 🔧 Node.js API Backend
├── 🗄️ PostgreSQL Database  
├── 📧 Email Campaign System
├── 📊 Analytics & Reporting
└── 🛡️ Security & Monitoring
```

---

## 🐳 **DEPLOYMENT**

### Services
| Service | Purpose | Port |
|---------|---------|------|
| **Caddy** | Reverse proxy, SSL | 80, 443 |
| **API** | Registration backend | 3000 |  
| **PostgreSQL** | Primary database | 5432 |
| **Redis** | Cache & job queue | 6379 |
| **Grafana** | Analytics dashboard | 3001 |
| **Workers** | Email & processing | - |

### Infrastructure
- 🐳 **Docker Compose** orchestration
- 🔒 **Automatic SSL** via Let's Encrypt  
- 📊 **Real-time monitoring** with Prometheus
- 💾 **Automated backups** of legal evidence
- 🛡️ **Security scanning** and alerts

---

## 📊 **LEGAL IMPACT**

### Current Status
- 🟢 **Active evidence collection**
- ⚖️ **Legal team engagement**  
- 📈 **Growing plaintiff database**
- 🎯 **Sherman Act violation documentation**

### Target Outcomes
- 💰 **Financial compensation** for affected users
- 🔓 **Bootloader unlock** mandate  
- 🚫 **Injunction** against future locking
- 📢 **Industry-wide** precedent

---

## 🛠️ **DEVELOPER GUIDE**

### Prerequisites
```bash
# macOS Requirements
brew install --cask android-platform-tools
brew install jq
```

### Project Structure
```
.
├── quick_setup.sh           # Automated configuration
├── deploy_remote.sh         # Server deployment  
├── mobile_device_tester.sh  # Device analysis
├── docker-compose.remote.yml# Container orchestration
├── api/                     # Backend Node.js
├── static/                  # Frontend assets
└── README_WORKFLOW.md       # Complete documentation
```

### Key Commands
```bash
# Setup everything
./quick_setup.sh

# Test connected devices
verizon-test

# Deploy to production
verizon-deploy  

# View server logs
verizon-logs

# Server status
verizon-status
```

---

## 📈 **EVIDENCE METRICS**

Track the impact of Verizon's anticompetitive practices:

- 📱 **Devices analyzed**: [View dashboard]
- 🔒 **Confirmed carrier locks**: [Live counter] 
- 👥 **Registered plaintiffs**: [Growing daily]
- 💰 **Estimated damages**: $850+ × affected devices

---

## ⚖️ **LEGAL FRAMEWORK**

### Sherman Antitrust Act Violations
- **Section 1**: Unreasonable restraints on trade
- **Section 2**: Monopolization and conspiracy  

### Consumer Protection Claims
- **Deceptive advertising** of "unlocked" devices
- **Undisclosed limitations** on device ownership
- **Anticompetitive tying** arrangements

### State Law Claims
- **Unfair competition** statutes
- **Consumer fraud** protection acts
- **Deceptive trade practices** laws

---

## 🤝 **CONTRIBUTING**

### How to Help
1. **🧪 Test your devices** - Run the testing suite
2. **📊 Share evidence** - Anonymous technical data only  
3. **📢 Spread awareness** - Social media campaigns
4. **💰 Register as plaintiff** - Join the class action
5. **👨‍💻 Contribute code** - Improve the platform

### Code Contributions
```bash
git checkout -b feature/your-improvement
git commit -m "feat: description of change"
git push origin feature/your-improvement
# Create pull request
```

---

## 🚨 **DISCLAIMER**

This project is for **legal evidence collection** only. We:

- ❌ **DO NOT** provide device unlocking services
- ❌ **DO NOT** bypass carrier restrictions  
- ❌ **DO NOT** distribute exploits or hacks
- ✅ **DO** collect forensic evidence for litigation
- ✅ **DO** support legal challenges to anticompetitive practices
- ✅ **DO** advocate for consumer rights

---

## 📞 **CONTACT & SUPPORT**

### Legal Team
- **Email**: [legal@verizonunlock.org](mailto:legal@verizonunlock.org)
- **Registration**: [register@verizonunlock.org](mailto:register@verizonunlock.org)

### Technical Support  
- **Issues**: [GitHub Issues](https://github.com/your-username/verizon-class-action/issues)
- **Discussions**: [GitHub Discussions](https://github.com/your-username/verizon-class-action/discussions)
- **Technical**: [admin@verizonunlock.org](mailto:admin@verizonunlock.org)

### Website
- **Main Site**: [https://verizonunlock.org](https://verizonunlock.org)
- **Admin Dashboard**: [https://verizonunlock.org/admin](https://verizonunlock.org/admin)
- **API Docs**: [https://api.verizonunlock.org/docs](https://api.verizonunlock.org/docs)

---

## 📄 **LICENSE**

MIT License - See [LICENSE](LICENSE) file for details.

**Legal Notice**: This software is provided for legitimate legal evidence collection. Users are responsible for compliance with applicable laws.

---

<div align="center">

**💪 FIGHT FOR YOUR DEVICE FREEDOM 💪**

**⚖️ TAKE ACTION AGAINST ANTICOMPETITIVE PRACTICES ⚖️**

**🔓 DEMAND BOOTLOADER UNLOCK RIGHTS 🔓**

[**JOIN THE CLASS ACTION →**](https://verizonunlock.org/register)

</div>

// Verizon Class Action Registration API
// Backend para procesar registros y gestionar base de datos

const express = require('express');
const cors = require('cors');
const nodemailer = require('nodemailer');
const fs = require('fs').promises;
const path = require('path');
const crypto = require('crypto');

const app = express();
const PORT = process.env.PORT || 3000;
const DATA_FILE = path.join(__dirname, 'registrations.json');

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.static('public'));

// Email transporter configuration
const emailTransporter = nodemailer.createTransporter({
    host: process.env.SMTP_HOST || 'mail.yourdomain.org',
    port: process.env.SMTP_PORT || 587,
    secure: false,
    auth: {
        user: process.env.SMTP_USER || 'legal@yourdomain.org',
        pass: process.env.SMTP_PASSWORD
    }
});

// Initialize data file if it doesn't exist
async function initializeDataFile() {
    try {
        await fs.access(DATA_FILE);
    } catch (error) {
        await fs.writeFile(DATA_FILE, JSON.stringify({
            registrations: [],
            statistics: {
                total_participants: 0,
                total_damages: 0,
                total_devices: 0,
                states_represented: [],
                device_models: {},
                registration_timeline: []
            }
        }, null, 2));
    }
}

// Load registrations data
async function loadData() {
    try {
        const data = await fs.readFile(DATA_FILE, 'utf8');
        return JSON.parse(data);
    } catch (error) {
        console.error('Error loading data:', error);
        return { registrations: [], statistics: {} };
    }
}

// Save registrations data
async function saveData(data) {
    try {
        await fs.writeFile(DATA_FILE, JSON.stringify(data, null, 2));
    } catch (error) {
        console.error('Error saving data:', error);
    }
}

// Generate unique registration ID
function generateRegistrationId() {
    const timestamp = Date.now().toString().slice(-6);
    const random = crypto.randomBytes(2).toString('hex').toUpperCase();
    return `VZ${timestamp}${random}`;
}

// Calculate estimated damages
function calculateDamages(purchasePrice) {
    const basePrice = parseFloat(purchasePrice) || 800;
    return Math.max(850, basePrice * 1.1);
}

// Update statistics
function updateStatistics(data) {
    const stats = {
        total_participants: data.registrations.length,
        total_damages: data.registrations.reduce((sum, reg) => sum + reg.estimated_damages, 0),
        total_devices: data.registrations.length,
        states_represented: [...new Set(data.registrations.map(reg => reg.state))],
        device_models: {},
        registration_timeline: []
    };

    // Count device models
    data.registrations.forEach(reg => {
        stats.device_models[reg.device_model] = (stats.device_models[reg.device_model] || 0) + 1;
    });

    // Create timeline (last 30 days)
    const thirtyDaysAgo = Date.now() - (30 * 24 * 60 * 60 * 1000);
    const recentRegistrations = data.registrations.filter(reg => 
        new Date(reg.timestamp).getTime() > thirtyDaysAgo
    );

    data.statistics = stats;
    return stats;
}

// Send confirmation email
async function sendConfirmationEmail(registration) {
    const subject = registration.language === 'es' ? 
        '✅ Confirmación de Registro - Demanda Colectiva Verizon' : 
        '✅ Registration Confirmed - Verizon Class Action';

    const htmlContent = registration.language === 'es' ? `
        <h2>¡Registro Exitoso en la Demanda Colectiva!</h2>
        <p>Estimado/a ${registration.first_name},</p>
        <p>Tu registro ha sido confirmado exitosamente en nuestra demanda colectiva contra Verizon por bloqueos permanentes de bootloader.</p>
        
        <h3>📋 Detalles de tu Registro:</h3>
        <ul>
            <li><strong>ID de Registro:</strong> ${registration.registration_id}</li>
            <li><strong>Dispositivo:</strong> ${registration.device_model}</li>
            <li><strong>Daños Estimados:</strong> $${registration.estimated_damages.toLocaleString()}</li>
            <li><strong>Fecha:</strong> ${new Date(registration.timestamp).toLocaleDateString('es-ES')}</li>
        </ul>
        
        <h3>🔥 Próximos Pasos:</h3>
        <ol>
            <li><strong>Comparte:</strong> Ayúdanos a crecer compartiendo en redes sociales</li>
            <li><strong>Evidencia:</strong> Guarda capturas de pantalla de tu dispositivo bloqueado</li>
            <li><strong>Actualizaciones:</strong> Te mantendremos informado del progreso legal</li>
        </ol>
        
        <p><strong>¡Juntos venceremos a Verizon! 💪</strong></p>
        
        <hr>
        <p><em>Este email confirma tu participación gratuita. No hay costos ocultos ni abogados individuales requeridos.</em></p>
    ` : `
        <h2>Class Action Registration Confirmed!</h2>
        <p>Dear ${registration.first_name},</p>
        <p>Your registration has been successfully confirmed in our class action lawsuit against Verizon for permanent bootloader locks.</p>
        
        <h3>📋 Your Registration Details:</h3>
        <ul>
            <li><strong>Registration ID:</strong> ${registration.registration_id}</li>
            <li><strong>Device:</strong> ${registration.device_model}</li>
            <li><strong>Estimated Damages:</strong> $${registration.estimated_damages.toLocaleString()}</li>
            <li><strong>Date:</strong> ${new Date(registration.timestamp).toLocaleDateString()}</li>
        </ul>
        
        <h3>🔥 Next Steps:</h3>
        <ol>
            <li><strong>Share:</strong> Help us grow by sharing on social media</li>
            <li><strong>Evidence:</strong> Save screenshots of your locked device</li>
            <li><strong>Updates:</strong> We'll keep you informed of legal progress</li>
        </ol>
        
        <p><strong>Together we will beat Verizon! 💪</strong></p>
        
        <hr>
        <p><em>This email confirms your free participation. No hidden costs or individual lawyers required.</em></p>
    `;

    try {
        await emailTransporter.sendMail({
            from: `"Verizon Class Action" <legal@${process.env.DOMAIN || 'yourdomain.org'}>`,
            to: registration.email,
            subject: subject,
            html: htmlContent
        });
        console.log(`Confirmation email sent to ${registration.email}`);
    } catch (error) {
        console.error('Error sending email:', error);
    }
}

// Routes

// Register new participant
app.post('/api/register', async (req, res) => {
    try {
        const data = await loadData();
        
        // Check for duplicate email
        const existingRegistration = data.registrations.find(reg => 
            reg.email.toLowerCase() === req.body.email.toLowerCase()
        );
        
        if (existingRegistration) {
            return res.status(400).json({ 
                error: 'Email already registered',
                existing_id: existingRegistration.registration_id 
            });
        }
        
        // Create new registration
        const registration = {
            ...req.body,
            registration_id: generateRegistrationId(),
            estimated_damages: calculateDamages(req.body.purchase_price),
            timestamp: new Date().toISOString(),
            ip_address: req.ip,
            user_agent: req.get('User-Agent')
        };
        
        // Add to data
        data.registrations.push(registration);
        updateStatistics(data);
        
        // Save data
        await saveData(data);
        
        // Send confirmation email
        await sendConfirmationEmail(registration);
        
        res.json({
            success: true,
            registration_id: registration.registration_id,
            estimated_damages: registration.estimated_damages,
            total_participants: data.statistics.total_participants
        });
        
        console.log(`New registration: ${registration.registration_id} (${registration.email})`);
        
    } catch (error) {
        console.error('Registration error:', error);
        res.status(500).json({ error: 'Registration failed' });
    }
});

// Get current statistics
app.get('/api/stats', async (req, res) => {
    try {
        const data = await loadData();
        updateStatistics(data);
        res.json(data.statistics);
    } catch (error) {
        console.error('Stats error:', error);
        res.status(500).json({ error: 'Failed to load statistics' });
    }
});

// Export registrations (protected endpoint)
app.get('/api/export/:token', async (req, res) => {
    try {
        // Simple token validation (replace with proper auth)
        const validToken = crypto.createHash('sha256')
            .update(process.env.EXPORT_SECRET || 'default_secret')
            .digest('hex').slice(0, 16);
            
        if (req.params.token !== validToken) {
            return res.status(403).json({ error: 'Invalid export token' });
        }
        
        const data = await loadData();
        
        res.setHeader('Content-Type', 'application/json');
        res.setHeader('Content-Disposition', 'attachment; filename=verizon_class_action_export.json');
        res.json(data);
        
    } catch (error) {
        console.error('Export error:', error);
        res.status(500).json({ error: 'Export failed' });
    }
});

// Legal report generation
app.get('/api/legal-report/:token', async (req, res) => {
    try {
        const validToken = crypto.createHash('sha256')
            .update(process.env.EXPORT_SECRET || 'default_secret')
            .digest('hex').slice(0, 16);
            
        if (req.params.token !== validToken) {
            return res.status(403).json({ error: 'Invalid token' });
        }
        
        const data = await loadData();
        const stats = updateStatistics(data);
        
        const report = {
            generated: new Date().toISOString(),
            case_title: "Class Action Lawsuit Against Verizon Communications Inc.",
            total_participants: stats.total_participants,
            estimated_total_damages: stats.total_damages,
            affected_states: stats.states_represented.length,
            device_breakdown: stats.device_models,
            legal_claims: [
                "Sherman Antitrust Act Violations (15 U.S.C. §§ 1, 2)",
                "Deceptive Trade Practices",
                "Consumer Protection Law Violations", 
                "Unfair Competition Claims"
            ],
            participant_summary: data.registrations.map(reg => ({
                id: reg.registration_id,
                state: reg.state,
                device: reg.device_model,
                damages: reg.estimated_damages,
                date: reg.timestamp
            }))
        };
        
        res.setHeader('Content-Type', 'application/json');
        res.setHeader('Content-Disposition', 'attachment; filename=legal_report.json');
        res.json(report);
        
    } catch (error) {
        console.error('Report generation error:', error);
        res.status(500).json({ error: 'Report generation failed' });
    }
});

// Health check
app.get('/api/health', (req, res) => {
    res.json({ status: 'OK', timestamp: new Date().toISOString() });
});

// Start server
async function startServer() {
    await initializeDataFile();
    
    app.listen(PORT, () => {
        console.log(`🚀 Verizon Class Action API running on port ${PORT}`);
        console.log(`📧 Email configured for: ${process.env.SMTP_USER || 'legal@yourdomain.org'}`);
        console.log(`💾 Data file: ${DATA_FILE}`);
    });
}

startServer().catch(console.error);

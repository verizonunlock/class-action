#!/usr/bin/env python3
"""
Sistema de Emails Automatizado para Demanda Colectiva Verizon
Automated Email System for Verizon Class Action
"""

import smtplib
import json
import os
from datetime import datetime
from email.mime.text import MimeText
from email.mime.multipart import MimeMultipart
from email.mime.base import MimeBase
from email import encoders
from pathlib import Path
import uuid

class VerizonEmailSystem:
    def __init__(self, domain, smtp_host, smtp_user, smtp_password, smtp_port=587):
        self.domain = domain
        self.smtp_host = smtp_host
        self.smtp_user = smtp_user
        self.smtp_password = smtp_password
        self.smtp_port = smtp_port
        self.registrations_file = 'registrations.json'
        
    def load_registrations(self):
        """Cargar registros existentes"""
        try:
            with open(self.registrations_file, 'r') as f:
                return json.load(f)
        except FileNotFoundError:
            return {"registrations": [], "statistics": {}}
    
    def save_registrations(self, data):
        """Guardar registros"""
        with open(self.registrations_file, 'w') as f:
            json.dump(data, f, indent=2)
    
    def send_email(self, to_email, subject, html_content, attachments=None):
        """Enviar email individual"""
        try:
            msg = MimeMultipart('alternative')
            msg['From'] = f"Verizon Class Action <{self.smtp_user}>"
            msg['To'] = to_email
            msg['Subject'] = subject
            
            # HTML content
            html_part = MimeText(html_content, 'html', 'utf-8')
            msg.attach(html_part)
            
            # Attachments
            if attachments:
                for attachment_path in attachments:
                    if os.path.exists(attachment_path):
                        with open(attachment_path, "rb") as attachment:
                            part = MimeBase('application', 'octet-stream')
                            part.set_payload(attachment.read())
                            encoders.encode_base64(part)
                            part.add_header(
                                'Content-Disposition',
                                f'attachment; filename= {os.path.basename(attachment_path)}'
                            )
                            msg.attach(part)
            
            # Send email
            with smtplib.SMTP(self.smtp_host, self.smtp_port) as server:
                server.starttls()
                server.login(self.smtp_user, self.smtp_password)
                server.send_message(msg)
                
            print(f"✅ Email sent to {to_email}")
            return True
            
        except Exception as e:
            print(f"❌ Error sending email to {to_email}: {e}")
            return False
    
    def send_confirmation_email(self, registration):
        """Enviar email de confirmación"""
        lang = registration.get('language', 'en')
        
        if lang == 'es':
            subject = f"✅ Confirmación #{registration['registration_id']} - Demanda Colectiva Verizon"
            html_content = f"""
            <html>
            <body style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
                <div style="background: linear-gradient(135deg, #1e40af, #3b82f6); color: white; padding: 30px; text-align: center;">
                    <h1>⚖️ DEMANDA COLECTIVA VERIZON</h1>
                    <h2>¡Registro Confirmado!</h2>
                </div>
                
                <div style="padding: 30px;">
                    <p>Estimado/a <strong>{registration['first_name']} {registration['last_name']}</strong>,</p>
                    
                    <p>Tu registro ha sido <strong>confirmado exitosamente</strong> en nuestra demanda colectiva contra Verizon Communications Inc. por bloqueos permanentes de bootloader en dispositivos Pixel.</p>
                    
                    <div style="background: #f8fafc; padding: 20px; border-radius: 10px; margin: 20px 0;">
                        <h3>📋 Detalles de tu Registro:</h3>
                        <ul>
                            <li><strong>ID de Registro:</strong> {registration['registration_id']}</li>
                            <li><strong>Dispositivo Afectado:</strong> {registration['device_model']}</li>
                            <li><strong>Estado/Provincia:</strong> {registration['state']}</li>
                            <li><strong>Daños Estimados:</strong> ${registration.get('estimated_damages', 850):,}</li>
                            <li><strong>Fecha de Registro:</strong> {datetime.now().strftime('%d/%m/%Y')}</li>
                        </ul>
                    </div>
                    
                    <div style="background: #fee2e2; border: 2px solid #dc2626; padding: 20px; border-radius: 10px; margin: 20px 0;">
                        <h3>🔥 TUS DERECHOS VIOLADOS:</h3>
                        <ul>
                            <li>🔒 <strong>Derecho de Propiedad:</strong> No puedes controlar tu dispositivo pagado</li>
                            <li>🛡️ <strong>Derecho de Privacidad:</strong> Obligado a usar servicios de Google</li>
                            <li>💰 <strong>Daño Económico:</strong> Funcionalidad perdida y reemplazos forzados</li>
                            <li>⚖️ <strong>Competencia Desleal:</strong> Monopolio sobre tu dispositivo</li>
                        </ul>
                    </div>
                    
                    <h3>🚀 Próximos Pasos Importantes:</h3>
                    <ol>
                        <li><strong>Comparte el Registro:</strong> Invita a otros usuarios afectados</li>
                        <li><strong>Documenta Evidencia:</strong> Capturas de pantalla del bloqueo</li>
                        <li><strong>Síguenos:</strong> Te mantendremos informado del progreso legal</li>
                        <li><strong>Prepárate:</strong> Puede que necesitemos testimonios adicionales</li>
                    </ol>
                    
                    <div style="background: #dcfce7; padding: 20px; border-radius: 10px; margin: 20px 0;">
                        <p><strong>💪 ¡JUNTOS VENCEREMOS A VERIZON!</strong></p>
                        <p>Esta demanda colectiva busca justicia para millones de usuarios afectados. Tu participación fortalece nuestro caso.</p>
                    </div>
                    
                    <hr style="margin: 30px 0;">
                    
                    <p><strong>Contacto Legal:</strong> legal@{self.domain}</p>
                    <p><strong>Sitio Web:</strong> https://{self.domain}</p>
                    <p><em>Este registro es completamente gratuito. Sin costos ocultos ni abogados individuales requeridos.</em></p>
                </div>
            </body>
            </html>
            """
        else:
            subject = f"✅ Confirmation #{registration['registration_id']} - Verizon Class Action"
            html_content = f"""
            <html>
            <body style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
                <div style="background: linear-gradient(135deg, #1e40af, #3b82f6); color: white; padding: 30px; text-align: center;">
                    <h1>⚖️ VERIZON CLASS ACTION</h1>
                    <h2>Registration Confirmed!</h2>
                </div>
                
                <div style="padding: 30px;">
                    <p>Dear <strong>{registration['first_name']} {registration['last_name']}</strong>,</p>
                    
                    <p>Your registration has been <strong>successfully confirmed</strong> in our class action lawsuit against Verizon Communications Inc. for permanent bootloader locks on Pixel devices.</p>
                    
                    <div style="background: #f8fafc; padding: 20px; border-radius: 10px; margin: 20px 0;">
                        <h3>📋 Your Registration Details:</h3>
                        <ul>
                            <li><strong>Registration ID:</strong> {registration['registration_id']}</li>
                            <li><strong>Affected Device:</strong> {registration['device_model']}</li>
                            <li><strong>State/Province:</strong> {registration['state']}</li>
                            <li><strong>Estimated Damages:</strong> ${registration.get('estimated_damages', 850):,}</li>
                            <li><strong>Registration Date:</strong> {datetime.now().strftime('%m/%d/%Y')}</li>
                        </ul>
                    </div>
                    
                    <div style="background: #fee2e2; border: 2px solid #dc2626; padding: 20px; border-radius: 10px; margin: 20px 0;">
                        <h3>🔥 YOUR VIOLATED RIGHTS:</h3>
                        <ul>
                            <li>🔒 <strong>Property Rights:</strong> Can't control your paid device</li>
                            <li>🛡️ <strong>Privacy Rights:</strong> Forced to use Google services</li>
                            <li>💰 <strong>Economic Harm:</strong> Lost functionality and forced replacements</li>
                            <li>⚖️ <strong>Unfair Competition:</strong> Monopoly over your device</li>
                        </ul>
                    </div>
                    
                    <h3>🚀 Important Next Steps:</h3>
                    <ol>
                        <li><strong>Share Registration:</strong> Invite other affected users</li>
                        <li><strong>Document Evidence:</strong> Screenshots of the lock</li>
                        <li><strong>Follow Us:</strong> We'll keep you updated on legal progress</li>
                        <li><strong>Prepare:</strong> We may need additional testimonies</li>
                    </ol>
                    
                    <div style="background: #dcfce7; padding: 20px; border-radius: 10px; margin: 20px 0;">
                        <p><strong>💪 TOGETHER WE WILL BEAT VERIZON!</strong></p>
                        <p>This class action seeks justice for millions of affected users. Your participation strengthens our case.</p>
                    </div>
                    
                    <hr style="margin: 30px 0;">
                    
                    <p><strong>Legal Contact:</strong> legal@{self.domain}</p>
                    <p><strong>Website:</strong> https://{self.domain}</p>
                    <p><em>This registration is completely free. No hidden costs or individual lawyers required.</em></p>
                </div>
            </body>
            </html>
            """
        
        return self.send_email(registration['email'], subject, html_content)
    
    def send_legal_update(self, update_content, language='both'):
        """Enviar actualizaciones legales masivas"""
        data = self.load_registrations()
        
        sent_count = 0
        failed_count = 0
        
        for registration in data['registrations']:
            reg_lang = registration.get('language', 'en')
            
            if language != 'both' and reg_lang != language:
                continue
                
            if reg_lang == 'es':
                subject = "📢 Actualización Legal - Demanda Colectiva Verizon"
                html_content = f"""
                <html>
                <body style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
                    <h2>📢 Actualización Legal Importante</h2>
                    <p>Hola {registration['first_name']},</p>
                    <div style="background: #f0f9ff; padding: 20px; border-radius: 10px;">
                        {update_content}
                    </div>
                    <p><strong>ID de Registro:</strong> {registration['registration_id']}</p>
                    <hr>
                    <p><em>Legal Team - {self.domain}</em></p>
                </body>
                </html>
                """
            else:
                subject = "📢 Legal Update - Verizon Class Action"
                html_content = f"""
                <html>
                <body style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
                    <h2>📢 Important Legal Update</h2>
                    <p>Hello {registration['first_name']},</p>
                    <div style="background: #f0f9ff; padding: 20px; border-radius: 10px;">
                        {update_content}
                    </div>
                    <p><strong>Registration ID:</strong> {registration['registration_id']}</p>
                    <hr>
                    <p><em>Legal Team - {self.domain}</em></p>
                </body>
                </html>
                """
            
            if self.send_email(registration['email'], subject, html_content):
                sent_count += 1
            else:
                failed_count += 1
                
        print(f"📧 Legal update sent: {sent_count} successful, {failed_count} failed")
        return sent_count, failed_count
    
    def send_welcome_series(self, registration):
        """Serie de emails de bienvenida (3 emails)"""
        lang = registration.get('language', 'en')
        
        emails = []
        
        if lang == 'es':
            emails = [
                {
                    'delay': 0,
                    'subject': f"🎯 Paso 1: Tu Lucha Contra Verizon Comienza - #{registration['registration_id']}",
                    'content': f"""
                    <h2>🎯 Paso 1: Tu Lucha Personal Contra Verizon</h2>
                    <p>Hola {registration['first_name']},</p>
                    <p>Tu dispositivo <strong>{registration['device_model']}</strong> vale más que ${registration.get('estimated_damages', 850):,} en funcionalidad robada por Verizon.</p>
                    <h3>🔥 ¿Por qué esto importa?</h3>
                    <ul>
                        <li>Verizon controla TU dispositivo que TÚ pagaste completamente</li>
                        <li>No puedes instalar GrapheneOS para mayor privacidad y seguridad</li>
                        <li>Estás forzado a usar servicios de Google que violan tu privacidad</li>
                        <li>Verizon viola leyes antimonopolio federales</li>
                    </ul>
                    <p><strong>¡Esta lucha es por TUS derechos fundamentales!</strong></p>
                    """
                },
                {
                    'delay': 86400,  # 1 día
                    'subject': f"⚖️ Paso 2: El Poder Legal Detrás de Tu Caso - #{registration['registration_id']}",
                    'content': f"""
                    <h2>⚖️ Paso 2: Fundamentos Legales de Tu Demanda</h2>
                    <p>Tu caso se basa en violaciones federales sólidas:</p>
                    <h3>📚 Leyes Violadas por Verizon:</h3>
                    <ul>
                        <li><strong>Sherman Antitrust Act §1 y §2</strong>: Monopolio ilegal</li>
                        <li><strong>Clayton Act</strong>: Restricciones anticompetitivas</li>
                        <li><strong>FTC Act</strong>: Prácticas comerciales engañosas</li>
                        <li><strong>Leyes Estatales</strong>: Protección al consumidor</li>
                    </ul>
                    <p><strong>Precedente Legal:</strong> Epic vs Apple ($3.6B en daños)</p>
                    <p>Tu caso es MÁS fuerte porque involucra hardware que ya pagaste.</p>
                    """
                },
                {
                    'delay': 172800,  # 2 días  
                    'subject': f"💰 Paso 3: Tu Compensación Potencial - #{registration['registration_id']}",
                    'content': f"""
                    <h2>💰 Paso 3: Compensación y Próximos Pasos</h2>
                    <h3>🎯 Tu Compensación Estimada:</h3>
                    <ul>
                        <li><strong>Daños Directos:</strong> ${registration.get('estimated_damages', 850):,}</li>
                        <li><strong>Daños Punitivos:</strong> $2,500+ (por conducta maliciosa)</li>
                        <li><strong>Honorarios Legales:</strong> GRATIS (base de contingencia)</li>
                    </ul>
                    
                    <div style="background: #dcfce7; padding: 20px; border-radius: 10px;">
                        <h3>🚀 ¿Qué Sigue Ahora?</h3>
                        <p>1. <strong>Reclutamiento:</strong> Necesitamos 10,000+ participantes</p>
                        <p>2. <strong>Presentación Legal:</strong> Demanda formal en corte federal</p>
                        <p>3. <strong>Discovery:</strong> Forzamos a Verizon a entregar documentos internos</p>
                        <p>4. <strong>Settlement o Trial:</strong> $2B+ en compensaciones</p>
                    </div>
                    
                    <p><strong>⏰ Tiempo estimado:</strong> 18-24 meses para resolución</p>
                    <p><strong>🎯 Tu papel:</strong> Compartir con otros usuarios afectados</p>
                    """
                }
            ]
        else:
            emails = [
                {
                    'delay': 0,
                    'subject': f"🎯 Step 1: Your Fight Against Verizon Begins - #{registration['registration_id']}",
                    'content': f"""
                    <h2>🎯 Step 1: Your Personal Fight Against Verizon</h2>
                    <p>Hello {registration['first_name']},</p>
                    <p>Your <strong>{registration['device_model']}</strong> is worth over ${registration.get('estimated_damages', 850):,} in functionality stolen by Verizon.</p>
                    <h3>🔥 Why This Matters:</h3>
                    <ul>
                        <li>Verizon controls YOUR device that YOU paid for completely</li>
                        <li>You can't install GrapheneOS for enhanced privacy and security</li>
                        <li>You're forced to use Google services that violate your privacy</li>
                        <li>Verizon violates federal antitrust laws</li>
                    </ul>
                    <p><strong>This fight is for YOUR fundamental rights!</strong></p>
                    """
                },
                {
                    'delay': 86400,  # 1 day
                    'subject': f"⚖️ Step 2: The Legal Power Behind Your Case - #{registration['registration_id']}",
                    'content': f"""
                    <h2>⚖️ Step 2: Legal Foundation of Your Lawsuit</h2>
                    <p>Your case is built on solid federal violations:</p>
                    <h3>📚 Laws Violated by Verizon:</h3>
                    <ul>
                        <li><strong>Sherman Antitrust Act §1 & §2</strong>: Illegal monopoly</li>
                        <li><strong>Clayton Act</strong>: Anticompetitive restrictions</li>
                        <li><strong>FTC Act</strong>: Deceptive business practices</li>
                        <li><strong>State Laws</strong>: Consumer protection</li>
                    </ul>
                    <p><strong>Legal Precedent:</strong> Epic vs Apple ($3.6B in damages)</p>
                    <p>Your case is STRONGER because it involves hardware you already paid for.</p>
                    """
                },
                {
                    'delay': 172800,  # 2 days
                    'subject': f"💰 Step 3: Your Potential Compensation - #{registration['registration_id']}",
                    'content': f"""
                    <h2>💰 Step 3: Compensation and Next Steps</h2>
                    <h3>🎯 Your Estimated Compensation:</h3>
                    <ul>
                        <li><strong>Direct Damages:</strong> ${registration.get('estimated_damages', 850):,}</li>
                        <li><strong>Punitive Damages:</strong> $2,500+ (for malicious conduct)</li>
                        <li><strong>Legal Fees:</strong> FREE (contingency basis)</li>
                    </ul>
                    
                    <div style="background: #dcfce7; padding: 20px; border-radius: 10px;">
                        <h3>🚀 What Happens Next?</h3>
                        <p>1. <strong>Recruitment:</strong> We need 10,000+ participants</p>
                        <p>2. <strong>Legal Filing:</strong> Formal lawsuit in federal court</p>
                        <p>3. <strong>Discovery:</strong> Force Verizon to turn over internal documents</p>
                        <p>4. <strong>Settlement or Trial:</strong> $2B+ in compensation</p>
                    </div>
                    
                    <p><strong>⏰ Estimated timeline:</strong> 18-24 months to resolution</p>
                    <p><strong>🎯 Your role:</strong> Share with other affected users</p>
                    """
                }
            ]
        
        # Send immediate confirmation
        if self.send_email(registration['email'], emails[0]['subject'], emails[0]['content']):
            print(f"✅ Confirmation email sent to {registration['email']}")
            return True
        else:
            print(f"❌ Failed to send confirmation to {registration['email']}")
            return False
    
    def generate_legal_report(self):
        """Generar reporte legal para abogados"""
        data = self.load_registrations()
        
        total_participants = len(data['registrations'])
        total_damages = sum(reg.get('estimated_damages', 850) for reg in data['registrations'])
        
        states = set(reg['state'] for reg in data['registrations'])
        devices = {}
        for reg in data['registrations']:
            device = reg['device_model']
            devices[device] = devices.get(device, 0) + 1
        
        report = f"""
        LEGAL REPORT - VERIZON CLASS ACTION LAWSUIT
        Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
        
        CASE OVERVIEW:
        - Total Registered Participants: {total_participants:,}
        - Estimated Total Damages: ${total_damages:,}
        - Affected States/Provinces: {len(states)}
        - Device Models Affected: {len(devices)}
        
        LEGAL FOUNDATION:
        1. Sherman Antitrust Act Violations (15 U.S.C. §§ 1, 2)
        2. Deceptive Trade Practices 
        3. Consumer Protection Law Violations
        4. Unfair Competition Claims
        
        DAMAGE BREAKDOWN:
        - Average per participant: ${total_damages/max(total_participants,1):.2f}
        - Hardware functionality loss: $850+ per device
        - Privacy violations: Forced Google services
        - Security vulnerabilities: Cannot install hardened OS
        
        DEVICE DISTRIBUTION:
        """
        
        for device, count in sorted(devices.items(), key=lambda x: x[1], reverse=True):
            report += f"        - {device}: {count} devices\n"
        
        report += f"""
        
        GEOGRAPHIC DISTRIBUTION:
        {', '.join(sorted(states))}
        
        RECOMMENDED LEGAL STRATEGY:
        1. Federal court filing (antitrust jurisdiction)
        2. Multi-district litigation coordination
        3. Expert testimony on technical harm
        4. Discovery of Verizon internal policies
        5. Settlement negotiations targeting $2B+ recovery
        
        CASE STRENGTH: EXCELLENT
        - Clear antitrust violations
        - Quantifiable economic harm  
        - Large affected class
        - Strong legal precedents
        
        Contact: legal@{self.domain}
        """
        
        return report
    
    def export_participant_data(self, export_format='csv'):
        """Exportar datos de participantes para uso legal"""
        data = self.load_registrations()
        
        if export_format == 'csv':
            import csv
            filename = f"verizon_participants_{datetime.now().strftime('%Y%m%d')}.csv"
            
            with open(filename, 'w', newline='', encoding='utf-8') as csvfile:
                fieldnames = ['registration_id', 'first_name', 'last_name', 'email', 
                             'phone', 'state', 'device_model', 'purchase_date', 
                             'purchase_price', 'estimated_damages', 'experience', 'timestamp']
                writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
                
                writer.writeheader()
                for reg in data['registrations']:
                    writer.writerow(reg)
                    
            print(f"✅ CSV exported: {filename}")
            return filename
        
        elif export_format == 'legal_json':
            filename = f"legal_evidence_{datetime.now().strftime('%Y%m%d')}.json"
            
            legal_data = {
                'case_title': 'Class Action Lawsuit Against Verizon Communications Inc.',
                'generated': datetime.now().isoformat(),
                'total_participants': len(data['registrations']),
                'total_estimated_damages': sum(reg.get('estimated_damages', 850) for reg in data['registrations']),
                'participants': data['registrations'],
                'legal_claims': [
                    'Sherman Antitrust Act Violations (15 U.S.C. §§ 1, 2)',
                    'Deceptive Trade Practices',
                    'Consumer Protection Law Violations',
                    'Unfair Competition Claims'
                ]
            }
            
            with open(filename, 'w') as f:
                json.dump(legal_data, f, indent=2)
                
            print(f"✅ Legal JSON exported: {filename}")
            return filename

def main():
    print("🚀 SISTEMA DE EMAILS VERIZON CLASS ACTION")
    print("=" * 50)
    
    # Configuración (reemplazar con valores reales)
    domain = input("Ingresa tu dominio (ej: verizonunlock.org): ").strip()
    smtp_host = input("SMTP Host (ej: mail.tudominio.org): ").strip()
    smtp_user = input("SMTP User (ej: legal@tudominio.org): ").strip()
    smtp_password = input("SMTP Password: ").strip()
    
    email_system = VerizonEmailSystem(domain, smtp_host, smtp_user, smtp_password)
    
    while True:
        print("\n📧 OPCIONES DISPONIBLES:")
        print("1. Enviar email de confirmación de prueba")
        print("2. Enviar actualización legal masiva") 
        print("3. Generar reporte legal")
        print("4. Exportar datos de participantes")
        print("5. Verificar configuración de email")
        print("0. Salir")
        
        choice = input("\nSelecciona opción: ").strip()
        
        if choice == "1":
            # Test confirmation email
            test_registration = {
                'registration_id': f'TEST{uuid.uuid4().hex[:6].upper()}',
                'first_name': 'Usuario',
                'last_name': 'Prueba',
                'email': input("Email para prueba: ").strip(),
                'device_model': 'Pixel 9 Pro Fold',
                'state': 'California',
                'estimated_damages': 1200,
                'language': 'es'
            }
            
            email_system.send_welcome_series(test_registration)
            
        elif choice == "2":
            update_content = input("Contenido de actualización legal: ").strip()
            language = input("Idioma (en/es/both): ").strip() or 'both'
            email_system.send_legal_update(update_content, language)
            
        elif choice == "3":
            report = email_system.generate_legal_report()
            print("\n" + "="*60)
            print(report)
            print("="*60)
            
            save = input("\n¿Guardar reporte en archivo? (y/n): ").lower()
            if save == 'y':
                with open(f'legal_report_{datetime.now().strftime("%Y%m%d")}.txt', 'w') as f:
                    f.write(report)
                print("✅ Reporte guardado")
                
        elif choice == "4":
            format_type = input("Formato (csv/legal_json): ").strip() or 'csv'
            filename = email_system.export_participant_data(format_type)
            print(f"✅ Datos exportados a: {filename}")
            
        elif choice == "5":
            # Test email configuration
            test_email = input("Email para verificar configuración: ").strip()
            test_content = "<h2>✅ Test Email</h2><p>Tu configuración de email funciona correctamente!</p>"
            
            if email_system.send_email(test_email, "✅ Test - Configuración Email", test_content):
                print("✅ Configuración de email FUNCIONA correctamente")
            else:
                print("❌ Error en configuración de email")
                
        elif choice == "0":
            break
        else:
            print("❌ Opción inválida")

if __name__ == "__main__":
    main()

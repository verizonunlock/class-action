#!/usr/bin/env python3
"""
CLASS ACTION REGISTRY - GLOBAL BILINGUAL
Registro para demanda colectiva contra Verizon / Verizon class action registry

Permite a usuarios afectados registrarse para la demanda colectiva
Allows affected users to register for the class action lawsuit
"""

import json
import hashlib
from datetime import datetime
import os

class BilingualClassActionRegistry:
    def __init__(self):
        self.registry_file = "/tmp/unlock_payload/class_action_registry.json"
        self.participants = []
        
        # Load existing registry if it exists
        if os.path.exists(self.registry_file):
            try:
                with open(self.registry_file, 'r') as f:
                    data = json.load(f)
                    self.participants = data.get('participants', [])
            except:
                self.participants = []
    
    def show_welcome_message(self):
        print("🔥⚖️ DEMANDA COLECTIVA GLOBAL / GLOBAL CLASS ACTION ⚖️🔥")
        print("="*70)
        print("🇺🇸 ENGLISH: Register for Verizon class action lawsuit")
        print("🇪🇸 ESPAÑOL: Regístrate para demanda colectiva contra Verizon") 
        print("="*70)
        print("🎯 OBJETIVO/OBJECTIVE: Libertad digital para todos / Digital freedom for all")
        print("💪 JUNTOS SOMOS FUERTES / TOGETHER WE ARE STRONG")
        print("="*70)
    
    def collect_participant_info(self):
        """Collect participant information bilingually"""
        print("\n🌍 SELECT LANGUAGE / SELECCIONA IDIOMA:")
        print("1. English")
        print("2. Español") 
        
        language = input("Choose/Elige (1 or 2): ").strip()
        
        if language == "2":
            return self.collect_spanish_info()
        else:
            return self.collect_english_info()
    
    def collect_english_info(self):
        """Collect information in English"""
        print("\n📱 DEVICE INFORMATION:")
        device_info = {
            'model': input("Pixel model (e.g., Pixel 9 Pro Fold): "),
            'purchase_date': input("Purchase date (MM/DD/YYYY): "),
            'purchase_price': input("Purchase price ($): "),
            'payment_status': input("Fully paid off? (yes/no): ").lower() == 'yes',
            'carrier_unlock_attempted': input("Did you request 'carrier unlock' from Verizon? (yes/no): ").lower() == 'yes'
        }
        
        print("\n👤 YOUR INFORMATION:")
        user_info = {
            'name': input("Full name: "),
            'email': input("Email address: "),
            'state': input("State (e.g., CA, NY, TX): ").upper(),
            'zip_code': input("ZIP code: "),
            'phone': input("Phone number (optional): ") or "Not provided",
            'language': 'English'
        }
        
        print("\n💔 HARM ASSESSMENT:")
        harm_info = {
            'wanted_graphene': input("Did you want to install GrapheneOS? (yes/no): ").lower() == 'yes',
            'wanted_custom_rom': input("Did you want to install other custom ROMs? (yes/no): ").lower() == 'yes',
            'security_concerns': input("Do you have security/privacy concerns? (yes/no): ").lower() == 'yes',
            'research_time': input("Did you spend time researching how to unlock? (yes/no): ").lower() == 'yes',
            'told_would_unlock': input("Were you told device would unlock after payoff? (yes/no): ").lower() == 'yes'
        }
        
        return {
            'device_info': device_info,
            'user_info': user_info, 
            'harm_info': harm_info,
            'registration_date': datetime.now().isoformat()
        }
    
    def collect_spanish_info(self):
        """Collect information in Spanish"""
        print("\n📱 INFORMACIÓN DEL DISPOSITIVO:")
        device_info = {
            'model': input("Modelo de Pixel (ej: Pixel 9 Pro Fold): "),
            'purchase_date': input("Fecha de compra (MM/DD/YYYY): "),
            'purchase_price': input("Precio de compra ($): "),
            'payment_status': input("¿Pagado completamente? (si/no): ").lower() in ['si', 'sí', 'yes'],
            'carrier_unlock_attempted': input("¿Solicitaste 'carrier unlock' a Verizon? (si/no): ").lower() in ['si', 'sí', 'yes']
        }
        
        print("\n👤 TU INFORMACIÓN:")
        user_info = {
            'name': input("Nombre completo: "),
            'email': input("Dirección de email: "),
            'state': input("Estado (ej: CA, NY, TX): ").upper(),
            'zip_code': input("Código postal: "),
            'phone': input("Número de teléfono (opcional): ") or "No proporcionado",
            'language': 'Español'
        }
        
        print("\n💔 EVALUACIÓN DE DAÑOS:")
        harm_info = {
            'wanted_graphene': input("¿Querías instalar GrapheneOS? (si/no): ").lower() in ['si', 'sí', 'yes'],
            'wanted_custom_rom': input("¿Querías instalar otras ROMs personalizadas? (si/no): ").lower() in ['si', 'sí', 'yes'],
            'security_concerns': input("¿Tienes preocupaciones de seguridad/privacidad? (si/no): ").lower() in ['si', 'sí', 'yes'],
            'research_time': input("¿Pasaste tiempo investigando cómo desbloquear? (si/no): ").lower() in ['si', 'sí', 'yes'],
            'told_would_unlock': input("¿Te dijeron que el dispositivo se desbloquearía después del pago? (si/no): ").lower() in ['si', 'sí', 'yes']
        }
        
        return {
            'device_info': device_info,
            'user_info': user_info,
            'harm_info': harm_info,
            'registration_date': datetime.now().isoformat()
        }
    
    def calculate_individual_damages(self, participant_data):
        """Calculate damages for individual participant"""
        base_damages = 200  # Base functionality loss
        
        harm_info = participant_data['harm_info']
        
        if harm_info.get('wanted_graphene'):
            base_damages += 500  # Privacy rights value
        if harm_info.get('wanted_custom_rom'):
            base_damages += 100  # Customization value  
        if harm_info.get('security_concerns'):
            base_damages += 150  # Security software value
        if harm_info.get('research_time'):
            base_damages += 100  # Time waste
        if harm_info.get('told_would_unlock'):
            base_damages += 200  # Deception damages
            
        return base_damages
    
    def register_participant(self, participant_data):
        """Register new participant in class action"""
        participant_data['participant_id'] = hashlib.md5(
            (participant_data['user_info']['email'] + 
             participant_data['registration_date']).encode()
        ).hexdigest()[:12]
        
        participant_data['estimated_damages'] = self.calculate_individual_damages(participant_data)
        
        self.participants.append(participant_data)
        self.save_registry()
        
        return participant_data['participant_id']
    
    def save_registry(self):
        """Save registry to file"""
        registry_data = {
            'total_participants': len(self.participants),
            'total_estimated_damages': sum(p['estimated_damages'] for p in self.participants),
            'last_updated': datetime.now().isoformat(),
            'participants': self.participants
        }
        
        with open(self.registry_file, 'w') as f:
            json.dump(registry_data, f, indent=2)
    
    def show_confirmation(self, participant_id, participant_data):
        """Show confirmation message"""
        lang = participant_data['user_info']['language']
        damages = participant_data['estimated_damages']
        
        if lang == 'Español':
            print(f"\n🎉 ¡REGISTRO EXITOSO EN DEMANDA COLECTIVA!")
            print(f"📋 ID de Participante: {participant_id}")
            print(f"💰 Daños Estimados: ${damages}")
            print(f"\n✅ PRÓXIMOS PASOS:")
            print(f"1. Presenta queja FCC: https://consumercomplaints.fcc.gov/")
            print(f"2. Comparte con otros usuarios Verizon")
            print(f"3. Mantente actualizado sobre el progreso del caso")
            print(f"4. Documenta cualquier evidencia adicional")
            print(f"\n🔥 ¡JUNTOS GANAREMOS LA LIBERTAD DIGITAL!")
        else:
            print(f"\n🎉 CLASS ACTION REGISTRATION SUCCESSFUL!")
            print(f"📋 Participant ID: {participant_id}")
            print(f"💰 Estimated Damages: ${damages}")
            print(f"\n✅ NEXT STEPS:")
            print(f"1. File FCC complaint: https://consumercomplaints.fcc.gov/")
            print(f"2. Share with other Verizon users")
            print(f"3. Stay updated on case progress")
            print(f"4. Document any additional evidence")
            print(f"\n🔥 TOGETHER WE WILL WIN DIGITAL FREEDOM!")
    
    def show_registry_stats(self):
        """Show current registry statistics"""
        total_participants = len(self.participants)
        total_damages = sum(p['estimated_damages'] for p in self.participants)
        
        print(f"\n📊 ESTADÍSTICAS DE DEMANDA COLECTIVA / CLASS ACTION STATS:")
        print(f"👥 Participantes Registrados / Registered Participants: {total_participants:,}")
        print(f"💰 Daños Totales Estimados / Total Estimated Damages: ${total_damages:,}")
        print(f"🎯 Objetivo / Target: 10,000 participantes para certificación de clase")
        print(f"🔥 ¡Comparte para crecer la clase! / Share to grow the class!")

def main():
    registry = BilingualClassActionRegistry()
    registry.show_welcome_message()
    
    try:
        while True:
            print(f"\n🌍 OPCIONES / OPTIONS:")
            print(f"1. Registrarse en demanda colectiva / Register for class action")
            print(f"2. Ver estadísticas / View statistics") 
            print(f"3. Salir / Exit")
            
            choice = input(f"\nSelecciona/Choose (1-3): ").strip()
            
            if choice == "1":
                participant_data = registry.collect_participant_info()
                participant_id = registry.register_participant(participant_data)
                registry.show_confirmation(participant_id, participant_data)
                
            elif choice == "2":
                registry.show_registry_stats()
                
            elif choice == "3":
                registry.show_registry_stats()
                print(f"\n🔥 ¡GRACIAS POR UNIRTE A LA LUCHA! / THANKS FOR JOINING THE FIGHT!")
                print(f"⚔️ ¡NUNCA NOS RENDIMOS! / WE NEVER SURRENDER!")
                break
            else:
                print("Opción inválida / Invalid option")
                
    except KeyboardInterrupt:
        print(f"\n⚠️ Registro interrumpido / Registration interrupted")
        registry.show_registry_stats()

if __name__ == "__main__":
    main()

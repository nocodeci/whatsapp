#!/usr/bin/env python3
"""
Script de test pour envoyer un message WhatsApp
"""
import requests
import json
import sys

def envoyer_message(recipient, message):
    """Envoie un message WhatsApp via l'API REST du bridge"""
    
    # URL de l'API (depuis l'hôte local, utilisez localhost:8081)
    # Depuis un conteneur Docker, utilisez: http://whatsapp-bridge:8080/api/send
    url = "http://localhost:8081/api/send"
    
    payload = {
        "recipient": recipient,
        "message": message
    }
    
    headers = {
        "Content-Type": "application/json"
    }
    
    try:
        print(f"📤 Envoi du message à {recipient}...")
        print(f"💬 Message: {message}")
        print(f"🌐 URL: {url}")
        print()
        
        response = requests.post(url, json=payload, headers=headers, timeout=30)
        
        print(f"📊 Statut HTTP: {response.status_code}")
        
        if response.status_code == 200:
            result = response.json()
            success = result.get("success", False)
            message_status = result.get("message", "Unknown")
            
            if success:
                print("✅ Message envoyé avec succès !")
                print(f"📝 Réponse: {message_status}")
                return True
            else:
                print("❌ Échec de l'envoi")
                print(f"📝 Erreur: {message_status}")
                return False
        else:
            print(f"❌ Erreur HTTP {response.status_code}")
            print(f"📝 Réponse: {response.text}")
            return False
            
    except requests.exceptions.ConnectionError:
        print("❌ Erreur de connexion")
        print("💡 Vérifiez que le service whatsapp-bridge est démarré:")
        print("   docker compose ps")
        print("   docker compose logs whatsapp-bridge")
        return False
    except requests.exceptions.Timeout:
        print("❌ Timeout - La requête a pris trop de temps")
        return False
    except Exception as e:
        print(f"❌ Erreur inattendue: {e}")
        return False

if __name__ == "__main__":
    # Numéro de téléphone (sans le +, juste le code pays + numéro)
    recipient = "2250703324674"  # +225 0703324674 sans le +
    
    # Message à envoyer
    message = "Bonjour ! Ceci est un message de test depuis le serveur MCP WhatsApp. 🚀"
    
    # Si des arguments sont fournis, les utiliser
    if len(sys.argv) > 1:
        recipient = sys.argv[1].replace("+", "").replace(" ", "").replace("-", "")
    if len(sys.argv) > 2:
        message = " ".join(sys.argv[2:])
    
    print("=" * 60)
    print("🧪 TEST D'ENVOI DE MESSAGE WHATSAPP")
    print("=" * 60)
    print()
    
    success = envoyer_message(recipient, message)
    
    print()
    print("=" * 60)
    if success:
        print("✅ Test réussi !")
    else:
        print("❌ Test échoué")
    print("=" * 60)
    
    sys.exit(0 if success else 1)


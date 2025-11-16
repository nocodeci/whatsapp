#!/bin/bash

# Script pour surveiller l'apparition du QR code WhatsApp

echo "🔍 Surveillance des logs WhatsApp Bridge..."
echo "📱 Le QR code apparaîtra ici quand le problème de version sera résolu"
echo "⏹️  Appuyez sur Ctrl+C pour arrêter"
echo ""
echo "=== Derniers logs ==="
docker compose logs whatsapp-bridge --tail 20
echo ""
echo "=== Surveillance en temps réel ==="
echo ""

# Surveiller les logs en temps réel
docker compose logs -f whatsapp-bridge 2>&1 | while IFS= read -r line; do
  # Afficher toutes les lignes
  echo "$line"
  
  # Détecter le QR code réel (chercher le message exact qui précède le QR code)
  # Le QR code apparaît après "Scan this QR code with your WhatsApp app:"
  if echo "$line" | grep -qi "Scan this QR code with your WhatsApp app"; then
    echo ""
    echo "🎯 QR CODE DÉTECTÉ ! Regardez les lignes suivantes pour le scanner"
    echo "📱 Ouvrez WhatsApp → Paramètres → Appareils liés → Lier un appareil"
    echo ""
  fi
  
  # Détecter la connexion réussie
  if echo "$line" | grep -qi "Connected to WhatsApp\|Successfully connected"; then
    echo ""
    echo "✅ CONNEXION RÉUSSIE !"
    echo ""
  fi
  
  # Détecter l'erreur de version (seulement pour les vraies erreurs)
  if echo "$line" | grep -qi "Client outdated.*405"; then
    echo ""
    echo "⚠️  Erreur de version détectée - Le QR code ne peut pas être généré"
    echo "💡 Le client ne peut pas se connecter à WhatsApp"
    echo "💡 Attendez une mise à jour de whatsmeow, puis reconstruisez :"
    echo "   docker compose build --no-cache whatsapp-bridge"
    echo "   docker compose up -d whatsapp-bridge"
    echo ""
  fi
done

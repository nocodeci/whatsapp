#!/bin/bash

# Script simple pour voir les logs WhatsApp Bridge

echo "📋 Logs WhatsApp Bridge"
echo "⏹️  Appuyez sur Ctrl+C pour arrêter"
echo ""
echo "💡 Le QR code apparaîtra ici quand le problème sera résolu"
echo "💡 Recherchez la ligne : 'Scan this QR code with your WhatsApp app:'"
echo ""

docker compose logs -f whatsapp-bridge



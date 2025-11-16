#!/bin/bash

# Script pour mettre à jour whatsmeow vers la dernière version disponible

echo "🔄 Mise à jour de whatsmeow..."

cd whatsapp-mcp/whatsapp-bridge || exit 1

# Vérifier si Go est installé (pour tester localement)
if command -v go &> /dev/null; then
    echo "📦 Mise à jour de la dépendance..."
    go get -u go.mau.fi/whatsmeow@latest
    go mod tidy
    
    echo "✅ Dépendances mises à jour localement"
    echo "📝 Fichiers modifiés: go.mod, go.sum"
    echo ""
    echo "🔨 Pour appliquer les changements, reconstruisez l'image Docker:"
    echo "   docker compose build --no-cache whatsapp-bridge"
    echo "   docker compose up -d whatsapp-bridge"
else
    echo "⚠️  Go n'est pas installé localement"
    echo "💡 La mise à jour se fera automatiquement lors du build Docker"
    echo ""
    echo "🔨 Pour forcer la mise à jour, reconstruisez l'image:"
    echo "   docker compose build --no-cache whatsapp-bridge"
    echo "   docker compose up -d whatsapp-bridge"
fi


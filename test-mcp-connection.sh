#!/bin/bash
# Script pour tester la connexion MCP au serveur WhatsApp

echo "🧪 Test de connexion MCP au serveur WhatsApp"
echo ""

# Vérifier que le serveur est en cours d'exécution
echo "1. Vérification du statut du serveur..."
if docker compose ps whatsapp-mcp-server | grep -q "Up"; then
    echo "   ✅ Serveur MCP en cours d'exécution"
else
    echo "   ❌ Serveur MCP non démarré"
    echo "   Démarrez avec: docker compose up -d whatsapp-mcp-server"
    exit 1
fi

# Vérifier que le port est accessible
echo ""
echo "2. Test de connexion TCP sur le port 9000..."
if docker compose exec -T whatsapp-mcp-server sh -c "nc -z localhost 9000" 2>/dev/null; then
    echo "   ✅ Port 9000 accessible"
else
    echo "   ⚠️  Port 9000 non accessible depuis le conteneur"
fi

# Tester depuis le réseau Docker
echo ""
echo "3. Test depuis le réseau Docker..."
if docker compose exec -T n8n sh -c "nc -z whatsapp-mcp-server 9000" 2>/dev/null; then
    echo "   ✅ Connexion possible depuis n8n"
else
    echo "   ⚠️  Connexion impossible depuis n8n"
    echo "   Vérifiez que n8n est sur le même réseau Docker"
fi

# Afficher les logs récents
echo ""
echo "4. Derniers logs du serveur MCP:"
docker compose logs --tail 5 whatsapp-mcp-server | grep -E "MCP|bridge|running|connected" || echo "   Aucun log récent"

echo ""
echo "📋 Instructions pour n8n:"
echo "   1. Ouvrez n8n: http://localhost:5678"
echo "   2. Allez dans Paramètres > MCP"
echo "   3. Ajoutez un serveur MCP:"
echo "      - Type: TCP"
echo "      - Host: whatsapp-mcp-server"
echo "      - Port: 9000"
echo "      - Protocol: MCP (JSON-RPC 2.0)"
echo ""
echo "✅ Test terminé"


# Guide : Utiliser le serveur MCP WhatsApp dans React/Next.js

Ce guide explique comment intégrer et utiliser le serveur MCP WhatsApp dans vos projets React et Next.js.

## 📋 Table des matières

1. [Vue d'ensemble](#vue-densemble)
2. [Méthode 1 : API HTTP (Recommandé)](#méthode-1--api-http-recommandé)
3. [Méthode 2 : Protocole MCP natif](#méthode-2--protocole-mcp-natif)
4. [Exemples React](#exemples-react)
5. [Exemples Next.js](#exemples-nextjs)
6. [Hooks React personnalisés](#hooks-react-personnalisés)
7. [Gestion des erreurs](#gestion-des-erreurs)

---

## Vue d'ensemble

Le serveur MCP WhatsApp expose deux interfaces :

1. **API HTTP** (port 8000) - **Plus simple à utiliser**
   - Endpoint : `http://whatsapp-mcp-server:8000/run_tool`
   - Format : POST avec JSON

2. **Protocole MCP TCP** (port 9000) - Pour les clients MCP natifs
   - Format : JSON-RPC 2.0 via TCP

Pour React/Next.js, nous recommandons d'utiliser l'**API HTTP** car elle est plus simple et plus directe.

---

## Méthode 1 : API HTTP (Recommandé)

### Configuration de base

#### Pour React (développement local)

```javascript
// config.js
const API_BASE_URL = process.env.REACT_APP_MCP_API_URL || 'http://localhost:8000';

export const MCP_ENDPOINT = `${API_BASE_URL}/run_tool`;
```

#### Pour Next.js

```javascript
// lib/mcp-config.js
const API_BASE_URL = process.env.NEXT_PUBLIC_MCP_API_URL || 'http://localhost:8000';

export const MCP_ENDPOINT = `${API_BASE_URL}/run_tool`;
```

### Fonction utilitaire pour appeler les outils MCP

```javascript
// utils/mcp-client.js

/**
 * Appelle un outil MCP via l'API HTTP
 * @param {string} tool - Nom de l'outil MCP
 * @param {object} params - Paramètres de l'outil
 * @returns {Promise<any>} Résultat de l'appel
 */
export async function callMCPTool(tool, params = {}) {
  try {
    const response = await fetch('http://localhost:8000/run_tool', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        tool,
        params,
      }),
    });

    if (!response.ok) {
      const error = await response.json();
      throw new Error(error.error || `HTTP error! status: ${response.status}`);
    }

    return await response.json();
  } catch (error) {
    console.error('Error calling MCP tool:', error);
    throw error;
  }
}
```

### Exemples d'utilisation

#### Envoyer un message

```javascript
import { callMCPTool } from './utils/mcp-client';

async function sendMessage(recipient, message) {
  try {
    const result = await callMCPTool('send_message', {
      recipient,
      message,
    });
    console.log('Message sent:', result);
    return result;
  } catch (error) {
    console.error('Failed to send message:', error);
    throw error;
  }
}

// Utilisation
sendMessage('+33612345678', 'Bonjour depuis React !');
```

#### Lister les chats

```javascript
import { callMCPTool } from './utils/mcp-client';

async function getChats(limit = 10) {
  try {
    const chats = await callMCPTool('list_chats', {
      limit,
      include_last_message: true,
    });
    return chats;
  } catch (error) {
    console.error('Failed to get chats:', error);
    throw error;
  }
}

// Utilisation
const chats = await getChats(20);
console.log('Chats:', chats);
```

#### Lister les messages d'un chat

```javascript
import { callMCPTool } from './utils/mcp-client';

async function getMessages(chatJid, limit = 20) {
  try {
    const messages = await callMCPTool('list_messages', {
      chat_jid: chatJid,
      limit,
    });
    return messages;
  } catch (error) {
    console.error('Failed to get messages:', error);
    throw error;
  }
}

// Utilisation
const messages = await getMessages('22554038858@s.whatsapp.net', 50);
console.log('Messages:', messages);
```

#### Rechercher des contacts

```javascript
import { callMCPTool } from './utils/mcp-client';

async function searchContacts(query) {
  try {
    const contacts = await callMCPTool('search_contacts', {
      query,
    });
    return contacts;
  } catch (error) {
    console.error('Failed to search contacts:', error);
    throw error;
  }
}

// Utilisation
const contacts = await searchContacts('Jean');
console.log('Contacts found:', contacts);
```

---

## Exemples React

### Composant pour envoyer un message

```jsx
// components/SendMessageForm.jsx
import { useState } from 'react';
import { callMCPTool } from '../utils/mcp-client';

export default function SendMessageForm() {
  const [recipient, setRecipient] = useState('');
  const [message, setMessage] = useState('');
  const [loading, setLoading] = useState(false);
  const [result, setResult] = useState(null);
  const [error, setError] = useState(null);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError(null);
    setResult(null);

    try {
      const response = await callMCPTool('send_message', {
        recipient,
        message,
      });
      setResult(response);
      setRecipient('');
      setMessage('');
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <div>
        <label htmlFor="recipient" className="block mb-2">
          Destinataire
        </label>
        <input
          id="recipient"
          type="text"
          value={recipient}
          onChange={(e) => setRecipient(e.target.value)}
          placeholder="+33612345678"
          required
          className="w-full px-4 py-2 border rounded"
        />
      </div>

      <div>
        <label htmlFor="message" className="block mb-2">
          Message
        </label>
        <textarea
          id="message"
          value={message}
          onChange={(e) => setMessage(e.target.value)}
          placeholder="Votre message..."
          required
          rows={4}
          className="w-full px-4 py-2 border rounded"
        />
      </div>

      <button
        type="submit"
        disabled={loading}
        className="px-6 py-2 bg-blue-500 text-white rounded hover:bg-blue-600 disabled:opacity-50"
      >
        {loading ? 'Envoi...' : 'Envoyer'}
      </button>

      {error && (
        <div className="p-4 bg-red-100 text-red-700 rounded">
          Erreur : {error}
        </div>
      )}

      {result && (
        <div className="p-4 bg-green-100 text-green-700 rounded">
          Message envoyé avec succès !
        </div>
      )}
    </form>
  );
}
```

### Composant pour lister les chats

```jsx
// components/ChatList.jsx
import { useState, useEffect } from 'react';
import { callMCPTool } from '../utils/mcp-client';

export default function ChatList() {
  const [chats, setChats] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    loadChats();
  }, []);

  const loadChats = async () => {
    setLoading(true);
    setError(null);

    try {
      const result = await callMCPTool('list_chats', {
        limit: 20,
        include_last_message: true,
      });
      setChats(result);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return <div>Chargement des chats...</div>;
  }

  if (error) {
    return <div className="text-red-500">Erreur : {error}</div>;
  }

  return (
    <div className="space-y-2">
      <h2 className="text-xl font-bold mb-4">Chats WhatsApp</h2>
      <button
        onClick={loadChats}
        className="mb-4 px-4 py-2 bg-gray-200 rounded hover:bg-gray-300"
      >
        Actualiser
      </button>
      {chats.length === 0 ? (
        <p>Aucun chat trouvé</p>
      ) : (
        <ul className="space-y-2">
          {chats.map((chat) => (
            <li
              key={chat.jid}
              className="p-4 border rounded hover:bg-gray-50 cursor-pointer"
            >
              <div className="font-semibold">{chat.name || chat.jid}</div>
              {chat.last_message && (
                <div className="text-sm text-gray-600 mt-1">
                  {chat.last_message.text}
                </div>
              )}
              {chat.last_message_time && (
                <div className="text-xs text-gray-400 mt-1">
                  {new Date(chat.last_message_time).toLocaleString()}
                </div>
              )}
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
```

### Composant pour afficher les messages d'un chat

```jsx
// components/MessageList.jsx
import { useState, useEffect } from 'react';
import { callMCPTool } from '../utils/mcp-client';

export default function MessageList({ chatJid }) {
  const [messages, setMessages] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    if (chatJid) {
      loadMessages();
    }
  }, [chatJid]);

  const loadMessages = async () => {
    if (!chatJid) return;

    setLoading(true);
    setError(null);

    try {
      const result = await callMCPTool('list_messages', {
        chat_jid: chatJid,
        limit: 50,
      });
      setMessages(result);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  if (!chatJid) {
    return <div>Sélectionnez un chat pour voir les messages</div>;
  }

  if (loading) {
    return <div>Chargement des messages...</div>;
  }

  if (error) {
    return <div className="text-red-500">Erreur : {error}</div>;
  }

  return (
    <div className="space-y-2">
      <div className="flex justify-between items-center mb-4">
        <h2 className="text-xl font-bold">Messages</h2>
        <button
          onClick={loadMessages}
          className="px-4 py-2 bg-gray-200 rounded hover:bg-gray-300"
        >
          Actualiser
        </button>
      </div>
      {messages.length === 0 ? (
        <p>Aucun message trouvé</p>
      ) : (
        <div className="space-y-2">
          {messages.map((msg) => (
            <div
              key={msg.id}
              className={`p-3 rounded ${
                msg.is_from_me
                  ? 'bg-blue-100 ml-auto'
                  : 'bg-gray-100 mr-auto'
              }`}
              style={{ maxWidth: '70%' }}
            >
              <div className="text-sm font-semibold mb-1">
                {msg.sender_name || msg.sender}
              </div>
              <div className="text-base">{msg.text || msg.content}</div>
              {msg.timestamp && (
                <div className="text-xs text-gray-500 mt-1">
                  {new Date(msg.timestamp).toLocaleString()}
                </div>
              )}
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
```

---

## Exemples Next.js

### API Route (Server-side)

```javascript
// pages/api/whatsapp/send-message.js (Pages Router)
// ou app/api/whatsapp/send-message/route.js (App Router)

export default async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const { recipient, message } = req.body;

  if (!recipient || !message) {
    return res.status(400).json({ error: 'Recipient and message are required' });
  }

  try {
    const response = await fetch('http://whatsapp-mcp-server:8000/run_tool', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        tool: 'send_message',
        params: {
          recipient,
          message,
        },
      }),
    });

    if (!response.ok) {
      const error = await response.json();
      throw new Error(error.error || 'Failed to send message');
    }

    const result = await response.json();
    return res.status(200).json(result);
  } catch (error) {
    console.error('Error sending message:', error);
    return res.status(500).json({ error: error.message });
  }
}
```

### App Router (Next.js 13+)

```javascript
// app/api/whatsapp/send-message/route.js

export async function POST(request) {
  try {
    const { recipient, message } = await request.json();

    if (!recipient || !message) {
      return Response.json(
        { error: 'Recipient and message are required' },
        { status: 400 }
      );
    }

    const response = await fetch('http://whatsapp-mcp-server:8000/run_tool', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        tool: 'send_message',
        params: {
          recipient,
          message,
        },
      }),
    });

    if (!response.ok) {
      const error = await response.json();
      throw new Error(error.error || 'Failed to send message');
    }

    const result = await response.json();
    return Response.json(result);
  } catch (error) {
    console.error('Error sending message:', error);
    return Response.json(
      { error: error.message },
      { status: 500 }
    );
  }
}
```

### Utilisation côté client

```jsx
// components/SendMessageForm.jsx (Next.js)
'use client';

import { useState } from 'react';

export default function SendMessageForm() {
  const [recipient, setRecipient] = useState('');
  const [message, setMessage] = useState('');
  const [loading, setLoading] = useState(false);
  const [result, setResult] = useState(null);
  const [error, setError] = useState(null);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError(null);
    setResult(null);

    try {
      const response = await fetch('/api/whatsapp/send-message', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          recipient,
          message,
        }),
      });

      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(errorData.error || 'Failed to send message');
      }

      const data = await response.json();
      setResult(data);
      setRecipient('');
      setMessage('');
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  // ... (même JSX que l'exemple React)
}
```

---

## Hooks React personnalisés

### Hook pour envoyer un message

```javascript
// hooks/useSendMessage.js
import { useState } from 'react';
import { callMCPTool } from '../utils/mcp-client';

export function useSendMessage() {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  const sendMessage = async (recipient, message) => {
    setLoading(true);
    setError(null);

    try {
      const result = await callMCPTool('send_message', {
        recipient,
        message,
      });
      return result;
    } catch (err) {
      setError(err.message);
      throw err;
    } finally {
      setLoading(false);
    }
  };

  return { sendMessage, loading, error };
}
```

### Hook pour lister les chats

```javascript
// hooks/useChats.js
import { useState, useEffect } from 'react';
import { callMCPTool } from '../utils/mcp-client';

export function useChats(limit = 20) {
  const [chats, setChats] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  const refresh = async () => {
    setLoading(true);
    setError(null);

    try {
      const result = await callMCPTool('list_chats', {
        limit,
        include_last_message: true,
      });
      setChats(result);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    refresh();
  }, [limit]);

  return { chats, loading, error, refresh };
}
```

### Hook pour les messages d'un chat

```javascript
// hooks/useMessages.js
import { useState, useEffect } from 'react';
import { callMCPTool } from '../utils/mcp-client';

export function useMessages(chatJid, limit = 50) {
  const [messages, setMessages] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  const refresh = async () => {
    if (!chatJid) return;

    setLoading(true);
    setError(null);

    try {
      const result = await callMCPTool('list_messages', {
        chat_jid: chatJid,
        limit,
      });
      setMessages(result);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    refresh();
  }, [chatJid, limit]);

  return { messages, loading, error, refresh };
}
```

### Utilisation des hooks

```jsx
// components/ChatApp.jsx
import { useChats } from '../hooks/useChats';
import { useMessages } from '../hooks/useMessages';
import { useState } from 'react';

export default function ChatApp() {
  const [selectedChat, setSelectedChat] = useState(null);
  const { chats, loading: chatsLoading, refresh: refreshChats } = useChats(20);
  const { messages, loading: messagesLoading, refresh: refreshMessages } = useMessages(
    selectedChat
  );

  return (
    <div className="flex h-screen">
      <div className="w-1/3 border-r">
        <ChatList
          chats={chats}
          loading={chatsLoading}
          onSelectChat={setSelectedChat}
          onRefresh={refreshChats}
        />
      </div>
      <div className="w-2/3">
        {selectedChat ? (
          <MessageList
            messages={messages}
            loading={messagesLoading}
            chatJid={selectedChat}
            onRefresh={refreshMessages}
          />
        ) : (
          <div className="p-8 text-center text-gray-500">
            Sélectionnez un chat pour voir les messages
          </div>
        )}
      </div>
    </div>
  );
}
```

---

## Gestion des erreurs

### Wrapper avec gestion d'erreurs avancée

```javascript
// utils/mcp-client.js (version améliorée)

export async function callMCPTool(tool, params = {}, options = {}) {
  const {
    timeout = 30000,
    retries = 0,
    onRetry = null,
  } = options;

  let lastError = null;

  for (let attempt = 0; attempt <= retries; attempt++) {
    try {
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), timeout);

      const response = await fetch('http://localhost:8000/run_tool', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          tool,
          params,
        }),
        signal: controller.signal,
      });

      clearTimeout(timeoutId);

      if (!response.ok) {
        const error = await response.json();
        throw new Error(error.error || `HTTP error! status: ${response.status}`);
      }

      return await response.json();
    } catch (error) {
      lastError = error;

      if (attempt < retries) {
        if (onRetry) {
          onRetry(attempt + 1, error);
        }
        // Attendre avant de réessayer (backoff exponentiel)
        await new Promise((resolve) =>
          setTimeout(resolve, Math.pow(2, attempt) * 1000)
        );
        continue;
      }

      throw error;
    }
  }

  throw lastError;
}
```

---

## Configuration pour la production

### Variables d'environnement

#### React (.env)

```env
REACT_APP_MCP_API_URL=http://localhost:8000
```

#### Next.js (.env.local)

```env
NEXT_PUBLIC_MCP_API_URL=http://localhost:8000
# Pour les API routes (server-side)
MCP_API_URL=http://whatsapp-mcp-server:8000
```

### Configuration avec proxy (Next.js)

```javascript
// next.config.js
module.exports = {
  async rewrites() {
    return [
      {
        source: '/api/whatsapp/:path*',
        destination: 'http://whatsapp-mcp-server:8000/:path*',
      },
    ];
  },
};
```

---

## Tous les outils disponibles

| Outil | Paramètres | Description |
|-------|------------|-------------|
| `send_message` | `recipient`, `message` | Envoyer un message |
| `list_chats` | `limit`, `page`, `query`, `include_last_message` | Lister les conversations |
| `list_messages` | `chat_jid`, `limit`, `query`, `after`, `before` | Lister les messages |
| `search_contacts` | `query` | Rechercher des contacts |
| `get_chat` | `chat_jid` | Obtenir les détails d'un chat |
| `send_file` | `recipient`, `file_path`, `file_type` | Envoyer un fichier |
| `send_audio_message` | `recipient`, `audio_path` | Envoyer un message audio |
| `download_media` | `message_id`, `chat_jid` | Télécharger un média |

---

## Dépannage

### Erreur CORS

Si vous obtenez des erreurs CORS, configurez le serveur pour autoriser votre domaine :

```python
# Dans dashboard_server.py, la méthode end_headers() ajoute déjà CORS
# Mais vous pouvez le personnaliser si nécessaire
```

### Erreur de connexion

Vérifiez que le serveur MCP est accessible :
```bash
curl http://localhost:8000/run_tool -X POST -H "Content-Type: application/json" -d '{"tool":"list_chats","params":{"limit":1}}'
```

### Erreur dans Next.js (server-side)

Utilisez le nom du service Docker dans les API routes :
```javascript
// ✅ Correct
const response = await fetch('http://whatsapp-mcp-server:8000/run_tool');

// ❌ Incorrect (ne fonctionnera pas dans les API routes)
const response = await fetch('http://localhost:8000/run_tool');
```

---

## Exemple complet : Application React

Voir le dossier `examples/react-app/` pour un exemple complet d'application React utilisant le serveur MCP WhatsApp.

---

## Ressources supplémentaires

- **Dashboard WhatsApp** : http://localhost:8000/ui
- **API Documentation** : Voir `GUIDE_N8N_MCP.md`
- **Logs du serveur** : `docker compose logs whatsapp-mcp-server`


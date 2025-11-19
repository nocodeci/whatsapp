// Exemple complet d'utilisation du serveur MCP WhatsApp dans React
// À copier dans votre projet React

// 1. Créer utils/mcp-client.js
export async function callMCPTool(tool, params = {}) {
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
}

// 2. Créer hooks/useWhatsApp.js
import { useState, useCallback } from 'react';
import { callMCPTool } from '../utils/mcp-client';

export function useWhatsApp() {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  const sendMessage = useCallback(async (recipient, message) => {
    setLoading(true);
    setError(null);
    try {
      return await callMCPTool('send_message', { recipient, message });
    } catch (err) {
      setError(err.message);
      throw err;
    } finally {
      setLoading(false);
    }
  }, []);

  const getChats = useCallback(async (limit = 20) => {
    setLoading(true);
    setError(null);
    try {
      return await callMCPTool('list_chats', { limit, include_last_message: true });
    } catch (err) {
      setError(err.message);
      throw err;
    } finally {
      setLoading(false);
    }
  }, []);

  const getMessages = useCallback(async (chatJid, limit = 50) => {
    setLoading(true);
    setError(null);
    try {
      return await callMCPTool('list_messages', { chat_jid: chatJid, limit });
    } catch (err) {
      setError(err.message);
      throw err;
    } finally {
      setLoading(false);
    }
  }, []);

  return {
    sendMessage,
    getChats,
    getMessages,
    loading,
    error,
  };
}

// 3. Utiliser dans un composant
import React, { useState, useEffect } from 'react';
import { useWhatsApp } from './hooks/useWhatsApp';

function WhatsAppApp() {
  const { sendMessage, getChats, getMessages, loading, error } = useWhatsApp();
  const [chats, setChats] = useState([]);
  const [selectedChat, setSelectedChat] = useState(null);
  const [messages, setMessages] = useState([]);
  const [recipient, setRecipient] = useState('');
  const [message, setMessage] = useState('');

  useEffect(() => {
    loadChats();
  }, []);

  useEffect(() => {
    if (selectedChat) {
      loadMessages();
    }
  }, [selectedChat]);

  const loadChats = async () => {
    try {
      const result = await getChats(20);
      setChats(result);
    } catch (err) {
      console.error('Failed to load chats:', err);
    }
  };

  const loadMessages = async () => {
    try {
      const result = await getMessages(selectedChat);
      setMessages(result);
    } catch (err) {
      console.error('Failed to load messages:', err);
    }
  };

  const handleSendMessage = async (e) => {
    e.preventDefault();
    try {
      await sendMessage(recipient, message);
      setRecipient('');
      setMessage('');
      alert('Message envoyé !');
    } catch (err) {
      alert('Erreur: ' + err.message);
    }
  };

  return (
    <div className="container mx-auto p-4">
      <h1 className="text-2xl font-bold mb-4">WhatsApp MCP</h1>

      {error && (
        <div className="bg-red-100 text-red-700 p-4 rounded mb-4">
          Erreur : {error}
        </div>
      )}

      <div className="grid grid-cols-2 gap-4">
        {/* Liste des chats */}
        <div className="border rounded p-4">
          <h2 className="text-xl font-bold mb-4">Chats</h2>
          <button
            onClick={loadChats}
            disabled={loading}
            className="mb-4 px-4 py-2 bg-blue-500 text-white rounded"
          >
            {loading ? 'Chargement...' : 'Actualiser'}
          </button>
          <ul className="space-y-2">
            {chats.map((chat) => (
              <li
                key={chat.jid}
                onClick={() => setSelectedChat(chat.jid)}
                className={`p-2 border rounded cursor-pointer ${
                  selectedChat === chat.jid ? 'bg-blue-100' : ''
                }`}
              >
                <div className="font-semibold">{chat.name || chat.jid}</div>
                {chat.last_message && (
                  <div className="text-sm text-gray-600">
                    {chat.last_message.text}
                  </div>
                )}
              </li>
            ))}
          </ul>
        </div>

        {/* Messages du chat sélectionné */}
        <div className="border rounded p-4">
          <h2 className="text-xl font-bold mb-4">Messages</h2>
          {selectedChat ? (
            <div className="space-y-2 max-h-96 overflow-y-auto">
              {messages.map((msg) => (
                <div
                  key={msg.id}
                  className={`p-2 rounded ${
                    msg.is_from_me ? 'bg-blue-100 ml-auto' : 'bg-gray-100'
                  }`}
                >
                  <div className="text-sm font-semibold">{msg.sender_name}</div>
                  <div>{msg.text || msg.content}</div>
                </div>
              ))}
            </div>
          ) : (
            <p className="text-gray-500">Sélectionnez un chat</p>
          )}
        </div>
      </div>

      {/* Formulaire d'envoi */}
      <div className="mt-8 border rounded p-4">
        <h2 className="text-xl font-bold mb-4">Envoyer un message</h2>
        <form onSubmit={handleSendMessage} className="space-y-4">
          <input
            type="text"
            value={recipient}
            onChange={(e) => setRecipient(e.target.value)}
            placeholder="Numéro (ex: +33612345678)"
            className="w-full px-4 py-2 border rounded"
            required
          />
          <textarea
            value={message}
            onChange={(e) => setMessage(e.target.value)}
            placeholder="Votre message..."
            rows={4}
            className="w-full px-4 py-2 border rounded"
            required
          />
          <button
            type="submit"
            disabled={loading}
            className="px-6 py-2 bg-green-500 text-white rounded hover:bg-green-600 disabled:opacity-50"
          >
            {loading ? 'Envoi...' : 'Envoyer'}
          </button>
        </form>
      </div>
    </div>
  );
}

export default WhatsAppApp;


import { useState, useEffect } from "react";
import ChatList from "./components/ChatList";
import MessageList from "./components/MessageList";
import ChatInput from "./components/ChatInput";
import * as api from "./api";
import "./App.css";

function App() {
  const [chats, setChats] = useState([]);
  const [selectedChat, setSelectedChat] = useState(null);
  const [messages, setMessages] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  // Load chats on mount
  useEffect(() => {
    loadChats();
  }, []);

  // Load messages when chat is selected
  useEffect(() => {
    if (selectedChat) {
      loadMessages(selectedChat.jid);
    } else {
      setMessages([]);
    }
  }, [selectedChat]);

  const loadChats = async () => {
    try {
      setLoading(true);
      setError(null);
      const result = await api.listChats();
      
      // Handle API response format
      if (result.error) {
        setError(result.error);
        setChats([]);
      } else if (Array.isArray(result)) {
        setChats(result);
      } else if (result.data && Array.isArray(result.data)) {
        setChats(result.data);
      } else {
        setChats([]);
      }
    } catch (err) {
      console.error("Error loading chats:", err);
      setError("Failed to load chats. Please check the API connection.");
      setChats([]);
    } finally {
      setLoading(false);
    }
  };

  const loadMessages = async (chatJid) => {
    try {
      setLoading(true);
      setError(null);
      const result = await api.listMessages(chatJid);
      
      // Handle API response format
      if (result.error) {
        setError(result.error);
        setMessages([]);
      } else if (Array.isArray(result)) {
        setMessages(result);
      } else if (result.data && Array.isArray(result.data)) {
        setMessages(result.data);
      } else {
        setMessages([]);
      }
    } catch (err) {
      console.error("Error loading messages:", err);
      setError("Failed to load messages.");
      setMessages([]);
    } finally {
      setLoading(false);
    }
  };

  const handleSendMessage = async (text) => {
    if (!selectedChat || !text.trim()) return;

    try {
      setError(null);
      // Extract phone number from JID (format: 1234567890@s.whatsapp.net)
      const recipient = selectedChat.jid.split("@")[0];
      
      const result = await api.sendMessage(recipient, text);
      
      if (result.error) {
        setError(result.error);
      } else if (result.success) {
        // Reload messages after sending
        await loadMessages(selectedChat.jid);
        // Reload chats to update last message
        await loadChats();
      } else {
        setError("Failed to send message");
      }
    } catch (err) {
      console.error("Error sending message:", err);
      setError("Failed to send message. Please try again.");
    }
  };

  return (
    <div className="h-screen flex flex-col bg-gray-100">
      {/* Header */}
      <div className="bg-blue-600 text-white p-4 shadow-md">
        <h1 className="text-2xl font-bold">WhatsApp Dashboard</h1>
        <p className="text-sm text-blue-100">Manage your WhatsApp conversations</p>
      </div>

      {/* Error message */}
      {error && (
        <div className="bg-red-100 border-l-4 border-red-500 text-red-700 p-4 m-4">
          <p className="font-bold">Error</p>
          <p>{error}</p>
        </div>
      )}

      {/* Main content */}
      <div className="flex-1 flex overflow-hidden">
        {/* Chat list */}
        <div className="w-1/3 border-r bg-white">
          <div className="p-4 border-b flex justify-between items-center">
            <h2 className="text-xl font-bold">Chats</h2>
            <button
              onClick={loadChats}
              className="px-3 py-1 bg-blue-600 text-white text-sm rounded hover:bg-blue-700"
              disabled={loading}
            >
              {loading ? "Loading..." : "Refresh"}
            </button>
          </div>
          
          {loading && chats.length === 0 ? (
            <div className="p-4 text-center text-gray-500">Loading chats...</div>
          ) : chats.length === 0 ? (
            <div className="p-4 text-center text-gray-500">No chats found</div>
          ) : (
            <ChatList
              chats={chats}
              onSelect={setSelectedChat}
              selectedChat={selectedChat}
            />
          )}
        </div>

        {/* Messages area */}
        <div className="flex-1 flex flex-col bg-white">
          {selectedChat ? (
            <>
              {/* Chat header */}
              <div className="p-4 border-b bg-gray-50">
                <h3 className="text-lg font-semibold">
                  {selectedChat.name || selectedChat.jid}
                </h3>
                <p className="text-sm text-gray-600">{selectedChat.jid}</p>
              </div>

              {/* Messages */}
              <MessageList messages={messages} />

              {/* Input */}
              <ChatInput onSend={handleSendMessage} />
            </>
          ) : (
            <div className="flex-1 flex items-center justify-center text-gray-500">
              <div className="text-center">
                <p className="text-xl mb-2">Select a chat to start</p>
                <p className="text-sm">Choose a conversation from the list on the left</p>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

export default App;

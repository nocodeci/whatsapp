import express from 'express';
import { makeWASocket, useMultiFileAuthState, DisconnectReason, fetchLatestBaileysVersion } from '@whiskeysockets/baileys';
import { Boom } from '@hapi/boom';
import pino from 'pino';
import qrcode from 'qrcode-terminal';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';
import fs from 'fs';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const app = express();
const PORT = 8080;

app.use(express.json());

// Store directory
const STORE_DIR = '/app/store';
const AUTH_DIR = join(STORE_DIR, 'auth');

// Ensure directories exist
if (!fs.existsSync(STORE_DIR)) {
  fs.mkdirSync(STORE_DIR, { recursive: true });
}
if (!fs.existsSync(AUTH_DIR)) {
  fs.mkdirSync(AUTH_DIR, { recursive: true });
}

// Logger
const logger = pino({ level: 'info' });

let sock = null;
let isConnected = false;

// Initialize WhatsApp connection
async function connectToWhatsApp() {
  const { state, saveCreds } = await useMultiFileAuthState(AUTH_DIR);
  
  const { version } = await fetchLatestBaileysVersion();
  
  sock = makeWASocket({
    version,
    logger,
    printQRInTerminal: true,
    auth: state,
    browser: ['WhatsApp Bridge', 'Chrome', '1.0.0'],
  });

  sock.ev.on('creds.update', saveCreds);

  sock.ev.on('connection.update', (update) => {
    const { connection, lastDisconnect, qr } = update;

    if (qr) {
      console.log('\n📱 Scan this QR code with your WhatsApp app:');
      qrcode.generate(qr, { small: true });
      console.log('\n');
    }

    if (connection === 'close') {
      const shouldReconnect = (lastDisconnect?.error)?.output?.statusCode !== DisconnectReason.loggedOut;
      
      if (shouldReconnect) {
        console.log('🔄 Reconnecting...');
        connectToWhatsApp();
      } else {
        console.log('❌ Logged out. Please scan QR code again.');
        isConnected = false;
      }
    } else if (connection === 'open') {
      console.log('✅ Connected to WhatsApp!');
      isConnected = true;
    }
  });

  sock.ev.on('messages.upsert', async (m) => {
    const messages = m.messages;
    for (const msg of messages) {
      if (!msg.key.fromMe && m.type === 'notify') {
        console.log(`📨 New message from ${msg.key.remoteJid}: ${msg.message?.conversation || 'Media/Other'}`);
      }
    }
  });
}

// API Routes

// Health check
app.get('/api/health', (req, res) => {
  res.json({
    status: 'ok',
    connected: isConnected,
    timestamp: new Date().toISOString()
  });
});

// Send message
app.post('/api/send', async (req, res) => {
  try {
    if (!isConnected || !sock) {
      return res.status(503).json({
        success: false,
        message: 'Not connected to WhatsApp. Please wait for connection.'
      });
    }

    const { recipient, message } = req.body;

    if (!recipient || !message) {
      return res.status(400).json({
        success: false,
        message: 'recipient and message are required'
      });
    }

    // Format JID
    const jid = recipient.includes('@') ? recipient : `${recipient}@s.whatsapp.net`;

    // Send message
    await sock.sendMessage(jid, { text: message });

    res.json({
      success: true,
      message: 'Message sent successfully'
    });
  } catch (error) {
    console.error('Error sending message:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

// Get connection status
app.get('/api/status', (req, res) => {
  res.json({
    connected: isConnected,
    timestamp: new Date().toISOString()
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`🚀 WhatsApp Bridge API running on port ${PORT}`);
  console.log('📱 Connecting to WhatsApp...');
  connectToWhatsApp();
});



#!/usr/bin/env python3
"""
HTTP server to serve the WhatsApp dashboard UI and provide API endpoints.
This runs alongside the MCP server to provide web UI access.
"""
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import urlparse, parse_qs
import os
import sys
import json
import requests
import base64

class DashboardHandler(BaseHTTPRequestHandler):
    """Handler for serving the dashboard UI and API."""
    
    def __init__(self, *args, **kwargs):
        # Set the directory to serve from
        self.dashboard_dir = os.path.join(os.path.dirname(__file__), 'ui')
        # Get WhatsApp bridge API URL
        self.bridge_url = os.getenv('WHATSAPP_BRIDGE_URL', 'http://whatsapp-bridge:8080/api')
        super().__init__(*args, **kwargs)
    
    def do_GET(self):
        """Handle GET requests - serve dashboard files."""
        parsed_path = urlparse(self.path)
        path = parsed_path.path
        
        # Serve dashboard UI
        if path == '/' or path == '/ui' or path.startswith('/ui/'):
            if path == '/' or path == '/ui':
                file_path = os.path.join(self.dashboard_dir, 'index.html')
            else:
                # Remove /ui prefix and serve file
                file_path = os.path.join(self.dashboard_dir, path[4:])  # Remove '/ui'
            
            if os.path.exists(file_path) and os.path.isfile(file_path):
                self.send_response(200)
                # Determine content type
                if file_path.endswith('.html'):
                    self.send_header('Content-type', 'text/html')
                elif file_path.endswith('.js'):
                    self.send_header('Content-type', 'application/javascript')
                elif file_path.endswith('.css'):
                    self.send_header('Content-type', 'text/css')
                elif file_path.endswith('.json'):
                    self.send_header('Content-type', 'application/json')
                else:
                    self.send_header('Content-type', 'application/octet-stream')
                self.end_headers()
                with open(file_path, 'rb') as f:
                    self.wfile.write(f.read())
            else:
                # For SPA routing, serve index.html
                index_path = os.path.join(self.dashboard_dir, 'index.html')
                if os.path.exists(index_path):
                    self.send_response(200)
                    self.send_header('Content-type', 'text/html')
                    self.end_headers()
                    with open(index_path, 'rb') as f:
                        self.wfile.write(f.read())
                else:
                    self.send_response(404)
                    self.end_headers()
        else:
            self.send_response(404)
            self.end_headers()
    
    def do_POST(self):
        """Handle POST requests - proxy to WhatsApp bridge API."""
        parsed_path = urlparse(self.path)
        path = parsed_path.path
        
        if path == '/run_tool':
            # Get request body
            content_length = int(self.headers.get('Content-Length', 0))
            post_data = self.rfile.read(content_length)
            
            try:
                data = json.loads(post_data.decode('utf-8'))
                tool_name = data.get('tool')
                params = data.get('params', {})
                
                # Log the request for debugging
                print(f"Dashboard API request: tool={tool_name}, params={params}", file=sys.stderr)
                
                # Map dashboard tools to bridge API endpoints
                if tool_name == 'send_message':
                    # Call WhatsApp bridge send endpoint
                    response = requests.post(
                        f"{self.bridge_url}/send",
                        json={
                            'recipient': params.get('recipient'),
                            'message': params.get('message')
                        },
                        timeout=30
                    )
                    result = response.json()
                    self.send_response(200)
                    self.send_header('Content-type', 'application/json')
                    self.end_headers()
                    self.wfile.write(json.dumps(result).encode())
                elif tool_name == 'list_chats':
                    # Call WhatsApp list_chats function
                    try:
                        # Add current directory to path for imports
                        if '/app' not in sys.path:
                            sys.path.insert(0, '/app')
                        from whatsapp import list_chats
                        chats = list_chats(
                            query=params.get('query'),
                            limit=params.get('limit', 20),
                            page=params.get('page', 0),
                            include_last_message=params.get('include_last_message', True),
                            sort_by=params.get('sort_by', 'last_active')
                        )
                        # Convert Chat objects to dictionaries
                        result = []
                        for chat in chats:
                            chat_dict = {
                                'jid': chat.jid,
                                'name': chat.name,
                                'last_message_time': chat.last_message_time.isoformat() if chat.last_message_time else None,
                                'last_message': {
                                    'text': chat.last_message,
                                    'sender': chat.last_sender,
                                    'is_from_me': chat.last_is_from_me
                                } if chat.last_message else None
                            }
                            result.append(chat_dict)
                        
                        self.send_response(200)
                        self.send_header('Content-type', 'application/json')
                        self.end_headers()
                        self.wfile.write(json.dumps(result).encode())
                    except Exception as e:
                        import traceback
                        error_trace = traceback.format_exc()
                        print(f"Error in list_chats: {e}", file=sys.stderr)
                        print(error_trace, file=sys.stderr)
                        self.send_response(500)
                        self.send_header('Content-type', 'application/json')
                        self.end_headers()
                        self.wfile.write(json.dumps({'error': str(e), 'traceback': error_trace}).encode())
                elif tool_name == 'list_messages':
                    # Call WhatsApp list_messages function
                    try:
                        # Add current directory to path for imports
                        if '/app' not in sys.path:
                            sys.path.insert(0, '/app')
                        from whatsapp import list_messages
                        messages = list_messages(
                            after=params.get('after'),
                            before=params.get('before'),
                            sender_phone_number=params.get('sender_phone_number'),
                            chat_jid=params.get('chat_jid'),
                            query=params.get('query'),
                            limit=params.get('limit', 20),
                            page=params.get('page', 0),
                            include_context=params.get('include_context', True),
                            context_before=params.get('context_before', 1),
                            context_after=params.get('context_after', 1)
                        )
                        # Convert Message objects to dictionaries
                        result = []
                        for msg in messages:
                            msg_dict = {
                                'id': msg.id,
                                'timestamp': msg.timestamp.isoformat() if msg.timestamp else None,
                                'sender': msg.sender,
                                'sender_name': msg.chat_name or msg.sender,
                                'sender_phone_number': msg.sender.split('@')[0] if '@' in msg.sender else msg.sender,
                                'text': msg.content,
                                'content': msg.content,
                                'is_from_me': msg.is_from_me,
                                'chat_jid': msg.chat_jid,
                                'chat_name': msg.chat_name,
                                'media_type': msg.media_type
                            }
                            result.append(msg_dict)
                        
                        self.send_response(200)
                        self.send_header('Content-type', 'application/json')
                        self.end_headers()
                        self.wfile.write(json.dumps(result).encode())
                    except Exception as e:
                        import traceback
                        error_trace = traceback.format_exc()
                        print(f"Error in list_messages: {e}", file=sys.stderr)
                        print(error_trace, file=sys.stderr)
                        self.send_response(500)
                        self.send_header('Content-type', 'application/json')
                        self.end_headers()
                        self.wfile.write(json.dumps({'error': str(e), 'traceback': error_trace}).encode())
                else:
                    self.send_response(400)
                    self.send_header('Content-type', 'application/json')
                    self.end_headers()
                    self.wfile.write(json.dumps({'error': f'Unknown tool: {tool_name}'}).encode())
            except Exception as e:
                import traceback
                error_trace = traceback.format_exc()
                print(f"Error in do_POST: {e}", file=sys.stderr)
                print(error_trace, file=sys.stderr)
                self.send_response(500)
                self.send_header('Content-type', 'application/json')
                self.end_headers()
                self.wfile.write(json.dumps({'error': str(e), 'traceback': error_trace}).encode())
        else:
            self.send_response(404)
            self.end_headers()
    
    def do_OPTIONS(self):
        """Handle preflight requests."""
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type, Authorization')
        self.end_headers()
    
    def end_headers(self):
        """Add CORS headers."""
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type, Authorization')
        super().end_headers()
    
    def log_message(self, format, *args):
        """Override to log to stderr."""
        sys.stderr.write(f"{self.address_string()} - {format % args}\n")

def main():
    """Start the dashboard server."""
    port = int(os.getenv('DASHBOARD_PORT', '8000'))
    
    # Check if UI directory exists
    ui_dir = os.path.join(os.path.dirname(__file__), 'ui')
    if not os.path.exists(ui_dir):
        print(f"Error: Dashboard UI directory not found at {ui_dir}", file=sys.stderr)
        print("Please build the dashboard first: cd whatsapp-dashboard && npm run build", file=sys.stderr)
        sys.exit(1)
    
    server_address = ('0.0.0.0', port)
    httpd = HTTPServer(server_address, DashboardHandler)
    
    print(f"Dashboard server running on http://0.0.0.0:{port}/ui", file=sys.stderr)
    print(f"Serving from: {ui_dir}", file=sys.stderr)
    print(f"Bridge API: {os.getenv('WHATSAPP_BRIDGE_URL', 'http://whatsapp-bridge:8080/api')}", file=sys.stderr)
    
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\nShutting down dashboard server...", file=sys.stderr)
        httpd.shutdown()

if __name__ == '__main__':
    main()

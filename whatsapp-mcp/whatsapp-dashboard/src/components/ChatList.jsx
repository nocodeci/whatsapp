export default function ChatList({ chats, onSelect, selectedChat }) {
  return (
    <div className="overflow-y-auto" style={{ height: "calc(100vh - 200px)" }}>
      {chats.map(chat => (
        <div
          key={chat.jid}
          onClick={() => onSelect(chat)}
          className={`p-4 cursor-pointer hover:bg-gray-200 border-b ${
            selectedChat?.jid === chat.jid ? "bg-blue-100" : ""
          }`}
        >
          <div className="font-semibold">{chat.name || chat.jid.split("@")[0]}</div>
          {chat.last_message && (
            <div className="text-sm text-gray-600 truncate mt-1">
              {chat.last_message.text || chat.last_message.content || ""}
            </div>
          )}
          {chat.last_message_time && (
            <div className="text-xs text-gray-400 mt-1">
              {new Date(chat.last_message_time).toLocaleString()}
          </div>
          )}
        </div>
      ))}
    </div>
  );
}

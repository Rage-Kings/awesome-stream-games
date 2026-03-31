class_name TwitchClient
extends Node
## Подключение к Twitch IRC (WebSocket) для чтения чата.

signal message_received(username: String, message: String)
signal connected()
signal disconnected()

var _ws: WebSocketPeer = WebSocketPeer.new()
var _channel: String = ""
var _connected: bool = false

const TWITCH_IRC_URL := "wss://irc-ws.chat.twitch.tv:443"


func connect_to_channel(channel: String, oauth_token: String) -> void:
	_channel = channel.to_lower()
	var err := _ws.connect_to_url(TWITCH_IRC_URL)
	if err != OK:
		push_error("TwitchClient: failed to connect, error: %d" % err)
		return
	# Auth is sent after connection is established in _process


func _process(_delta: float) -> void:
	_ws.poll()
	var state := _ws.get_ready_state()

	if state == WebSocketPeer.STATE_OPEN:
		if not _connected:
			_connected = true
			_authenticate()
		while _ws.get_available_packet_count() > 0:
			var packet := _ws.get_packet().get_string_from_utf8()
			_parse_irc(packet)
	elif state == WebSocketPeer.STATE_CLOSED:
		if _connected:
			_connected = false
			disconnected.emit()


func _authenticate() -> void:
	# oauth_token should be stored securely; passed via connect_to_channel
	# For now, anonymous connection (justinfan)
	_ws.send_text("CAP REQ :twitch.tv/tags twitch.tv/commands")
	_ws.send_text("NICK justinfan12345")
	_ws.send_text("JOIN #%s" % _channel)
	connected.emit()


func _parse_irc(raw: String) -> void:
	for line in raw.split("\r\n", false):
		if line.begins_with("PING"):
			_ws.send_text("PONG :tmi.twitch.tv")
			continue
		if "PRIVMSG" in line:
			var username := _extract_username(line)
			var message := _extract_message(line)
			if username != "" and message != "":
				message_received.emit(username, message)


func _extract_username(line: String) -> String:
	var display_name_tag := "display-name="
	var idx := line.find(display_name_tag)
	if idx >= 0:
		var start := idx + display_name_tag.length()
		var end := line.find(";", start)
		if end > start:
			return line.substr(start, end - start)
	# Fallback: parse from prefix
	var prefix_start := line.find(":")
	var prefix_end := line.find("!", prefix_start)
	if prefix_start >= 0 and prefix_end > prefix_start:
		return line.substr(prefix_start + 1, prefix_end - prefix_start - 1)
	return ""


func _extract_message(line: String) -> String:
	var privmsg_idx := line.find("PRIVMSG")
	if privmsg_idx < 0:
		return ""
	var msg_start := line.find(":", privmsg_idx)
	if msg_start < 0:
		return ""
	return line.substr(msg_start + 1)

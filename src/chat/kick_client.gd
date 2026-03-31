class_name KickClient
extends Node
## Подключение к чату Kick через Pusher WebSocket.

signal message_received(username: String, message: String)
signal connected()
signal disconnected()

var _ws: WebSocketPeer = WebSocketPeer.new()
var _channel_id: String = ""
var _connected: bool = false

const KICK_PUSHER_URL := "wss://ws-us2.pusher.com/app/32cbd69e4b950bf97679?protocol=7&client=js&version=7.6.0&flash=false"


func connect_to_channel(channel_id: String) -> void:
	_channel_id = channel_id
	var err := _ws.connect_to_url(KICK_PUSHER_URL)
	if err != OK:
		push_error("KickClient: failed to connect, error: %d" % err)


func _process(_delta: float) -> void:
	_ws.poll()
	var state := _ws.get_ready_state()

	if state == WebSocketPeer.STATE_OPEN:
		if not _connected:
			_connected = true
			_subscribe()
		while _ws.get_available_packet_count() > 0:
			var packet := _ws.get_packet().get_string_from_utf8()
			_parse_message(packet)
	elif state == WebSocketPeer.STATE_CLOSED:
		if _connected:
			_connected = false
			disconnected.emit()


func _subscribe() -> void:
	var subscribe_msg := JSON.stringify({
		"event": "pusher:subscribe",
		"data": {"channel": "chatrooms.%s.v2" % _channel_id}
	})
	_ws.send_text(subscribe_msg)
	connected.emit()


func _parse_message(raw: String) -> void:
	var json := JSON.new()
	if json.parse(raw) != OK:
		return
	var data: Dictionary = json.data
	var event: String = data.get("event", "")

	if event == "App\\Events\\ChatMessageEvent":
		var inner_json := JSON.new()
		if inner_json.parse(data.get("data", "")) != OK:
			return
		var msg_data: Dictionary = inner_json.data
		var username: String = msg_data.get("sender", {}).get("username", "")
		var content: String = msg_data.get("content", "")
		if username != "" and content != "":
			message_received.emit(username, content)
	elif event == "pusher:ping":
		_ws.send_text(JSON.stringify({"event": "pusher:pong"}))

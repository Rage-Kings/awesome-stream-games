extends Node
## Единая точка подключения к чатам Twitch и Kick.
## Парсит сообщения и эмитит команды для мини-игр.

signal chat_message_received(platform: String, username: String, message: String)
signal chat_command_received(platform: String, username: String, command: String, args: Array[String])

const COMMAND_PREFIX := "!"

var twitch_client: TwitchClient = null
var kick_client: KickClient = null


func _ready() -> void:
	twitch_client = TwitchClient.new()
	add_child(twitch_client)
	twitch_client.message_received.connect(_on_message.bind("twitch"))

	kick_client = KickClient.new()
	add_child(kick_client)
	kick_client.message_received.connect(_on_message.bind("kick"))


func connect_twitch(channel: String, oauth_token: String) -> void:
	twitch_client.connect_to_channel(channel, oauth_token)


func connect_kick(channel_id: String) -> void:
	kick_client.connect_to_channel(channel_id)


func _on_message(username: String, message: String, platform: String) -> void:
	chat_message_received.emit(platform, username, message)
	if message.begins_with(COMMAND_PREFIX):
		var parts := message.trim_prefix(COMMAND_PREFIX).split(" ", false)
		if parts.size() > 0:
			var command := parts[0].to_lower()
			var args: Array[String] = []
			for i in range(1, parts.size()):
				args.append(parts[i])
			chat_command_received.emit(platform, username, command, args)

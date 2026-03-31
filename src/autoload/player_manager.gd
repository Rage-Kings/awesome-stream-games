extends Node
## Отслеживает игроков-зрителей, которые присоединились через чат.

signal player_joined(player_name: String)
signal player_left(player_name: String)

var players: Dictionary = {}  # player_name -> PlayerData


func _ready() -> void:
	ChatManager.chat_command_received.connect(_on_chat_command)


func _on_chat_command(platform: String, username: String, command: String, args: Array[String]) -> void:
	if command == "join":
		add_player(username, platform)
	elif command == "leave":
		remove_player(username)


func add_player(player_name: String, platform: String) -> void:
	if player_name in players:
		return
	var data := PlayerData.new()
	data.player_name = player_name
	data.platform = platform
	players[player_name] = data
	player_joined.emit(player_name)


func remove_player(player_name: String) -> void:
	if player_name not in players:
		return
	players.erase(player_name)
	player_left.emit(player_name)


func get_active_players() -> Array[String]:
	var names: Array[String] = []
	for key in players:
		names.append(key)
	return names


func get_player_count() -> int:
	return players.size()

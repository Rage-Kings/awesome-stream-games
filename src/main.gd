extends Node2D
## Главная сцена: лобби, запуск мини-игр, отображение результатов.

@onready var status_label: Label = $UI/HUD/StatusLabel
@onready var player_count_label: Label = $UI/HUD/PlayerCount
@onready var leaderboard_container: VBoxContainer = $UI/HUD/Leaderboard
@onready var game_container: Node2D = $GameContainer

## Список сцен мини-игр для ротации.
@export var minigame_scenes: Array[PackedScene] = []

var _current_minigame_idx: int = 0


func _ready() -> void:
	PlayerManager.player_joined.connect(_on_player_joined)
	PlayerManager.player_left.connect(_on_player_left)
	GameManager.minigame_started.connect(_on_minigame_started)
	GameManager.minigame_ended.connect(_on_minigame_ended)
	GameManager.scores_updated.connect(_update_leaderboard)

	# TODO: загрузить настройки из конфига
	# ChatManager.connect_twitch("channel_name", "oauth:token")
	# ChatManager.connect_kick("channel_id")


func _on_player_joined(player_name: String) -> void:
	_update_player_count()


func _on_player_left(player_name: String) -> void:
	_update_player_count()


func _update_player_count() -> void:
	player_count_label.text = "Игроков: %d" % PlayerManager.get_player_count()


func _on_minigame_started(minigame_name: String) -> void:
	status_label.text = "Игра: %s" % minigame_name


func _on_minigame_ended(minigame_name: String, _results: Dictionary) -> void:
	status_label.text = "ЛОББИ — напишите !join в чате"


func _update_leaderboard() -> void:
	for child in leaderboard_container.get_children():
		child.queue_free()
	var top := GameManager.get_leaderboard(5)
	for i in top.size():
		var label := Label.new()
		label.text = "%d. %s — %d" % [i + 1, top[i].name, top[i].score]
		leaderboard_container.add_child(label)


func start_next_minigame() -> void:
	if minigame_scenes.is_empty():
		return
	var scene := minigame_scenes[_current_minigame_idx]
	_current_minigame_idx = (_current_minigame_idx + 1) % minigame_scenes.size()
	GameManager.start_minigame(scene)

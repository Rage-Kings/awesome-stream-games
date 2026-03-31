extends Node
## Управляет жизненным циклом мини-игр: выбор, запуск, завершение, подсчёт очков.

signal minigame_started(minigame_name: String)
signal minigame_ended(minigame_name: String, results: Dictionary)
signal scores_updated()

enum State { LOBBY, PLAYING, RESULTS }

var state: State = State.LOBBY
var current_minigame: BaseMinigame = null
var scores: Dictionary = {}  # player_name -> int

@export var time_between_games: float = 10.0


func _ready() -> void:
	pass


func start_minigame(minigame_scene: PackedScene) -> void:
	if state != State.LOBBY:
		return
	state = State.PLAYING
	current_minigame = minigame_scene.instantiate() as BaseMinigame
	add_child(current_minigame)
	current_minigame.game_finished.connect(_on_minigame_finished)
	minigame_started.emit(current_minigame.minigame_name)


func _on_minigame_finished(results: Dictionary) -> void:
	for player_name in results:
		if player_name not in scores:
			scores[player_name] = 0
		scores[player_name] += results[player_name]
	scores_updated.emit()
	var mg_name := current_minigame.minigame_name
	current_minigame.queue_free()
	current_minigame = null
	state = State.RESULTS
	minigame_ended.emit(mg_name, results)
	await get_tree().create_timer(time_between_games).timeout
	state = State.LOBBY


func get_leaderboard(top_n: int = 10) -> Array[Dictionary]:
	var sorted: Array[Dictionary] = []
	for player_name in scores:
		sorted.append({"name": player_name, "score": scores[player_name]})
	sorted.sort_custom(func(a, b): return a.score > b.score)
	return sorted.slice(0, top_n)


func reset_scores() -> void:
	scores.clear()
	scores_updated.emit()

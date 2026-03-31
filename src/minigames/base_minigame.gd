class_name BaseMinigame
extends Node2D
## Базовый класс для всех мини-игр.
## Наследуйте этот класс и переопределяйте виртуальные методы.

signal game_finished(results: Dictionary)

## Уникальное имя мини-игры.
@export var minigame_name: String = "base"

## Длительность мини-игры в секундах.
@export var duration: float = 30.0

var time_remaining: float = 0.0
var is_running: bool = false
var _results: Dictionary = {}  # player_name -> score


func _ready() -> void:
	ChatManager.chat_command_received.connect(_on_chat_command)
	start()


func start() -> void:
	time_remaining = duration
	is_running = true
	_on_start()


func _process(delta: float) -> void:
	if not is_running:
		return
	time_remaining -= delta
	if time_remaining <= 0.0:
		finish()


func finish() -> void:
	if not is_running:
		return
	is_running = false
	_on_finish()
	game_finished.emit(_results)


func add_score(player_name: String, points: int) -> void:
	if player_name not in _results:
		_results[player_name] = 0
	_results[player_name] += points


## Переопределите: вызывается при старте мини-игры.
func _on_start() -> void:
	pass


## Переопределите: вызывается при завершении мини-игры.
func _on_finish() -> void:
	pass


## Переопределите: обработка команд чата.
func _on_chat_command(platform: String, username: String, command: String, args: Array[String]) -> void:
	pass

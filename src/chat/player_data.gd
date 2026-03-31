class_name PlayerData
extends RefCounted
## Данные об игроке-зрителе.

var player_name: String = ""
var platform: String = ""  # "twitch" or "kick"
var join_time: int = 0
var total_score: int = 0


func _init() -> void:
	join_time = Time.get_ticks_msec()

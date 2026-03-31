class_name QuizMinigame
extends BaseMinigame
## Мини-игра «Викторина». Зрители отвечают на вопросы командой !answer <вариант>.

@export var questions: Array[Dictionary] = []
# Формат: [{"question": "...", "options": ["A", "B", "C", "D"], "correct": 0}]

var current_question_index: int = 0
var answered_players: Dictionary = {}  # player_name -> bool (для текущего вопроса)

@export var points_per_correct: int = 10
@export var time_per_question: float = 15.0

var question_timer: float = 0.0


func _on_start() -> void:
	minigame_name = "quiz"
	if questions.is_empty():
		# Пример вопросов по умолчанию
		questions = [
			{"question": "2 + 2 = ?", "options": ["3", "4", "5", "6"], "correct": 1},
			{"question": "Столица Франции?", "options": ["Лондон", "Берлин", "Париж", "Рим"], "correct": 2},
		]
	_show_question()


func _process(delta: float) -> void:
	super._process(delta)
	if not is_running:
		return
	question_timer -= delta
	if question_timer <= 0.0:
		_next_question()


func _on_chat_command(platform: String, username: String, command: String, args: Array[String]) -> void:
	if not is_running or command != "answer" or args.is_empty():
		return
	if username in answered_players:
		return

	var answer := args[0].to_int() - 1  # Игроки отвечают 1-4, индексы 0-3
	answered_players[username] = true

	if current_question_index < questions.size():
		var q: Dictionary = questions[current_question_index]
		if answer == q.correct:
			add_score(username, points_per_correct)


func _show_question() -> void:
	question_timer = time_per_question
	answered_players.clear()
	# TODO: обновить UI с текущим вопросом


func _next_question() -> void:
	current_question_index += 1
	if current_question_index >= questions.size():
		finish()
	else:
		_show_question()

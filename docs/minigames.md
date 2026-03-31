# Мини-игры

## Базовый класс: BaseMinigame

Файл: `src/minigames/base_minigame.gd`

Все мини-игры наследуют `BaseMinigame` (extends Node2D). Базовый класс предоставляет:

- **Таймер** — автоматический обратный отсчёт (`duration` секунд), по истечении вызывается `finish()`
- **Подсчёт очков** — метод `add_score(player_name, points)` накапливает очки
- **Сигнал завершения** — `game_finished(results)` автоматически отправляет результаты в GameManager

### Виртуальные методы

```gdscript
## Вызывается при старте мини-игры
func _on_start() -> void:
    pass

## Вызывается при завершении (до отправки результатов)
func _on_finish() -> void:
    pass

## Обработка команд из чата
func _on_chat_command(platform: String, username: String, command: String, args: Array[String]) -> void:
    pass
```

### Свойства

| Свойство       | Тип    | Описание                      |
|----------------|--------|-------------------------------|
| `minigame_name`| String | Уникальное имя мини-игры      |
| `duration`     | float  | Длительность в секундах       |
| `time_remaining`| float | Оставшееся время              |
| `is_running`   | bool   | Запущена ли мини-игра         |

## Создание новой мини-игры

### 1. Скрипт

Создать файл в `src/minigames/`:

```gdscript
class_name MyMinigame
extends BaseMinigame

func _on_start() -> void:
    minigame_name = "my_game"
    duration = 30.0
    # Инициализация игры

func _on_chat_command(platform: String, username: String, command: String, args: Array[String]) -> void:
    if command != "my_command":
        return
    # Логика обработки команды
    add_score(username, 10)

func _on_finish() -> void:
    # Очистка, финальные подсчёты
    pass
```

### 2. Сцена

Создать `.tscn` в `scenes/minigames/`:
- Корневой узел: Node2D
- Прикрепить скрипт мини-игры
- Добавить визуальные элементы (спрайты, UI)

### 3. Регистрация

Добавить PackedScene в массив `minigame_scenes` на главной сцене (`scenes/main.tscn` → узел Main → Inspector).

## Существующие мини-игры

### Quiz (Викторина)

- Файл: `src/minigames/quiz_minigame.gd`
- Команда: `!answer <номер>` (1–4)
- Механика: серия вопросов с вариантами ответов, очки за правильный ответ
- Настройки: `points_per_correct`, `time_per_question`, массив `questions`

Формат вопроса:
```gdscript
{"question": "Текст вопроса", "options": ["A", "B", "C", "D"], "correct": 0}
# correct — индекс правильного ответа (0-3)
```

## Жизненный цикл мини-игры

```
GameManager.start_minigame(scene)
    │
    ▼
BaseMinigame._ready()
    │
    ▼
_on_start()              ◄── инициализация
    │
    ▼
_process() loop          ◄── обратный отсчёт, _on_chat_command()
    │
    ▼ (time_remaining <= 0)
finish()
    │
    ▼
_on_finish()             ◄── финализация
    │
    ▼
game_finished.emit()     ──► GameManager._on_minigame_finished()
```

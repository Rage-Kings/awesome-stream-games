# API-интеграция

Планируется внешний бэкенд на Laravel для хранения данных и статистики. Godot взаимодействует с ним через HTTP-запросы.

## HTTPRequest в Godot

Godot предоставляет класс `HTTPRequest` для асинхронных HTTP-запросов:

```gdscript
var http := HTTPRequest.new()
add_child(http)
http.request_completed.connect(_on_response)

# GET
http.request("https://api.example.com/scores")

# POST с JSON-телом
var headers := ["Content-Type: application/json", "Authorization: Bearer <token>"]
var body := JSON.stringify({"player": "username", "score": 100})
http.request("https://api.example.com/scores", headers, HTTPClient.METHOD_POST, body)
```

Обработка ответа:

```gdscript
func _on_response(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
    if result != HTTPRequest.RESULT_SUCCESS:
        push_error("HTTP request failed: %d" % result)
        return
    var json = JSON.parse_string(body.get_string_from_utf8())
    # обработка json
```

## Планируемые эндпоинты

> Это черновик — конкретные эндпоинты будут определены при разработке Laravel API.

| Метод  | Эндпоинт              | Описание                          |
|--------|------------------------|-----------------------------------|
| GET    | `/api/leaderboard`     | Глобальный лидерборд              |
| POST   | `/api/games`           | Сохранить результат мини-игры     |
| GET    | `/api/players/{name}`  | Профиль и статистика игрока       |
| POST   | `/api/players`         | Регистрация нового игрока         |

## Рекомендации

- Один `HTTPRequest` — один запрос одновременно. Для параллельных запросов создавайте несколько экземпляров.
- Используйте `await` для упрощения асинхронного кода (Godot 4.x):
  ```gdscript
  var http := HTTPRequest.new()
  add_child(http)
  http.request("https://api.example.com/data")
  var response = await http.request_completed
  # response = [result, response_code, headers, body]
  ```
- Храните URL бэкенда и токены в конфиге или переменных окружения, не хардкодьте в скриптах.
- Обрабатывайте ошибки сети — стрим не должен падать из-за недоступности API.

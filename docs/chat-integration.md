# Чат-интеграция

## Поддерживаемые платформы

### Twitch

- Протокол: IRC через WebSocket (`wss://irc-ws.chat.twitch.tv:443`)
- Аутентификация: анонимная (justinfan) для чтения, OAuth для записи
- Файл: `src/chat/twitch_client.gd`

Подключение:
```gdscript
ChatManager.connect_twitch("channel_name", "oauth:your_token")
```

### Kick

- Протокол: Pusher WebSocket API
- Канал: `chatrooms.<channel_id>.v2`
- Событие: `App\Events\ChatMessageEvent`
- Файл: `src/chat/kick_client.gd`

Подключение:
```gdscript
ChatManager.connect_kick("12345")  # channel_id
```

## Формат команд

Все команды начинаются с префикса `!` (определён в `ChatManager.COMMAND_PREFIX`).

```
!команда аргумент1 аргумент2
```

### Встроенные команды

| Команда   | Обработчик    | Описание                    |
|-----------|---------------|-----------------------------|
| `!join`   | PlayerManager | Присоединиться к игре       |
| `!leave`  | PlayerManager | Покинуть игру               |

### Команды мини-игр

Каждая мини-игра определяет свои команды в методе `_on_chat_command()`. Примеры:

| Команда        | Мини-игра | Описание                         |
|----------------|-----------|----------------------------------|
| `!answer <N>`  | Quiz      | Ответить на вопрос (1, 2, 3, 4) |

## Сигналы ChatManager

```gdscript
# Любое сообщение из чата
signal chat_message_received(platform: String, username: String, message: String)

# Распознанная команда (после парсинга)
signal chat_command_received(platform: String, username: String, command: String, args: Array[String])
```

- `platform` — `"twitch"` или `"kick"`
- `command` — имя команды без `!`, в нижнем регистре
- `args` — массив аргументов после команды

## Добавление новой платформы

1. Создать класс-клиент в `src/chat/`, реализующий сигнал `message_received(username, message)`
2. Добавить экземпляр в `ChatManager._ready()` и подключить сигнал через `_on_message.bind("platform_name")`
3. Добавить метод подключения `connect_<platform>()`

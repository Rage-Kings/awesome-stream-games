# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Stream Game — набор мини-игр для стримеров на Godot 4.6. Зрители участвуют через чат Twitch и Kick, используя команды с префиксом `!` (например, `!join`, `!answer 2`).

## Architecture

### Autoloads (глобальные синглтоны, загружаются в project.godot)
- **GameManager** — жизненный цикл мини-игр (LOBBY → PLAYING → RESULTS), глобальный счёт и лидерборд
- **ChatManager** — единая точка подключения к Twitch/Kick, парсит `!команды` из чата и эмитит сигналы `chat_command_received`
- **PlayerManager** — реестр активных игроков-зрителей, реагирует на `!join`/`!leave`

### Chat Clients (src/chat/)
- **TwitchClient** — WebSocket подключение к Twitch IRC (`wss://irc-ws.chat.twitch.tv`), парсит PRIVMSG
- **KickClient** — WebSocket подключение через Pusher API, подписка на канал `chatrooms.<id>.v2`
- **PlayerData** — RefCounted-ресурс с данными игрока (имя, платформа, время входа)

### Minigames (src/minigames/)
- **BaseMinigame** — абстрактный базовый класс. Все мини-игры наследуют его и переопределяют `_on_start()`, `_on_finish()`, `_on_chat_command()`. Имеет встроенный таймер (`duration`) и метод `add_score()`.
- Каждая мини-игра — отдельная сцена (.tscn) + скрипт, наследующий BaseMinigame.

### Поток данных
```
Twitch/Kick Chat → TwitchClient/KickClient → ChatManager (сигнал) → PlayerManager / BaseMinigame._on_chat_command()
                                                                    → GameManager (управляет жизненным циклом)
```

## Adding a New Minigame

1. Создать скрипт в `src/minigames/`, наследующий `BaseMinigame`
2. Переопределить `_on_start()`, `_on_finish()`, `_on_chat_command()`
3. Использовать `add_score(username, points)` для начисления очков
4. Создать сцену (.tscn) в `scenes/minigames/` с корневым узлом типа Node2D и прикрепить скрипт
5. Добавить сцену в массив `minigame_scenes` на главной сцене

## Commands

```bash
# Открыть проект в редакторе Godot
godot --editor --path .

# Запустить проект
godot --path .

# Запустить конкретную сцену
godot --path . scenes/main.tscn

# Экспорт (после настройки export presets в редакторе)
godot --headless --path . --export-release "Linux"
```

## Conventions

- Язык скриптов: GDScript
- Все скрипты — в `src/`, сцены — в `scenes/`, ассеты — в `assets/`
- Чат-команды всегда начинаются с `!` (COMMAND_PREFIX в ChatManager)
- Комментарии в коде и UI-текст — на русском языке
- class_name используется для глобально доступных классов (TwitchClient, KickClient, PlayerData, BaseMinigame)

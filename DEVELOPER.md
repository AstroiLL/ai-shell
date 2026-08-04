# 🛠 Разработка ai-shell

Руководство для программистов: архитектура, соглашения, как добавлять
новые режимы и опции.

---

## 📁 Структура проекта

```
ai-shell/
├── bin/ai            # ★ Единственный исполняемый файл (Python)
├── completions/       # bash/zsh автодополнения
│   ├── ai.bash        #   bash completion
│   └── ai.zsh         #   zsh completion
├── main.py           # Python-стаб для uv run ai ...
├── pyproject.toml    # uv-метаданные
├── README.md         # Пользовательская документация
├── INSTALL.md        # Установка и настройка
├── DEVELOPER.md      # Это файл
└── AGENTS.md         # Контекст для Hermes при работе над проектом
```

Весь код живет в одном файле — `bin/ai`. Это сознательное решение:
- **Zero setup** — скрипт работает сразу после `chmod +x`, никаких `pip install`
- **Одна точка изменений** — легко править, не нужно собирать пакет
- **Python 3.12+ stdlib only** — никаких внешних зависимостей

Если проект разрастётся (Фаза 4+), имеет смысл вынести роли в YAML,
REPL — в отдельный модуль. Но для MVP монолит оптимален.

---

## 🧠 Архитектура

```
┌─────────────────────────────────────────────────────┐
│  bin/ai                                              │
│                                                      │
│  build_parser()    →  argparse (режимы + опции)      │
│       │                                              │
│       ▼                                              │
│  main()            →  определяет режим, собирает     │
│       │                вход (args + stdin)            │
│       ▼                                              │
│  MODE_MAP          →  {general, shell, explain, code} │
│       │                                              │
│       ▼                                              │
│  hermes_query()    →  subprocess(hermes -z "prompt") │
│                                                      │
│  hermes_send()     →  subprocess(hermes send --to)   │
│                                                      │
│  copy_to_clipboard() →  xclip / wl-copy              │
│                                                      │
│  stylize()         →  пост-процессинг (цвета,       │
│                        подсветка кода)               │
└─────────────────────────────────────────────────────┘
```

### Поток вызова

1. `build_parser()` — настраивает argparse
2. `main()` — определяет режим, собирает запрос + stdin
3. `MODE_MAP[mode](input_text, args)` — вызывает соответствующий обработчик
4. Обработчик формирует промпт и вызывает `hermes_query()`
5. Ответ проходит через `stylize()` (подсветка) и печатается
6. Если `--send` — дополнительно вызывается `hermes_send()`

---

## 🔌 Как добавить новый режим

Допустим, хочешь добавить режим `--translate` для перевода текста.

### 1. Добавить промпт в PROMPTS (секция Configuration)

```python
PROMPTS: dict[str, str] = {
    # ... существующие режимы ...
    "translate": (
        "Переведи следующий текст с языка оригинала на {target_lang}. "
        "Ответь только переводом, без пояснений.\n\n{input}"
    ),
}
```

### 2. Написать функцию-обработчик (секция Режимы)

```python
def mode_translate(input_text: str, args: argparse.Namespace) -> str:
    """Перевод текста."""
    prompt = PROMPTS["translate"].format(
        input=input_text,
        target_lang=getattr(args, "target_lang", "русский"),
    )
    return hermes_query(prompt, model=args.model, provider=args.provider)
```

### 3. Зарегистрировать в MODE_MAP

```python
MODE_MAP = {
    "general": mode_general,
    "shell": mode_shell,
    "explain": mode_explain,
    "code": mode_code,
    "translate": mode_translate,  # <-- добавить
}
```

### 4. Добавить аргумент в build_parser()

```python
parser.add_argument(
    "--translate",
    action="store_true",
    help="Режим перевода",
)
parser.add_argument(
    "--target-lang",
    default="русский",
    help="Язык перевода (по умолчанию: русский)",
)
```

### 5. Добавить логику выбора режима в main()

```python
if args.translate:
    mode = "translate"
```

Готово. Новый режим подхватится автоматически.

---

## 📐 Соглашения

### Обработчики режимов

```python
def mode_xxx(input_text: str, args: argparse.Namespace) -> str:
    """Описание: что делает режим.
    
    Аргументы:
        input_text: собранный запрос (args + stdin)
        args: все опции парсера
    
    Возвращает:
        строку ответа (уже готовую к печати)
    """
    ...
    return response
```

- Сигнатура всегда `(input_text: str, args: argparse.Namespace) -> str`
- Промпты хранятся в `PROMPTS` с форматированием через `str.format()`
- Ошибки возвращаются строкой с `color("текст", "red")`
- Обработчик **не печатает** — возвращает строку, печать в `main()`

### Промпты

```python
PROMPTS["my_mode"] = (
    "Контекст/инструкция модели. "
    "Чётко опиши формат ответа.\n\n{input}"
)
```

- Хранятся в верхней секции файла (Configuration)
- Используют `{query}` или `{input}` для подстановки
- Пиши на русском (пользователь русскоязычный)
- Чётко указывай формат ответа

### Цвета

```python
color("текст", "green")   # код, команды
color("текст", "blue")    # вывод программ
color("текст", "dim")     # второстепенное, подсказки
color("текст", "red")     # ошибки
color("текст", "bold")    # акцент
```

- Цвета применяются только если `sys.stdout.isatty()`
- Пользователь может отключить `--no-color`
- Для подсветки кода в ответе — `stylize()`

### Stdin + args

При комбинировании пайпа и аргументов:

```python
# echo "context" | ai "prompt"
# → "Контекст:\ncontext\n\nЗапрос:\nprompt"
```

Для режима explain stdin полностью заменяет аргументы.

---

## 🧪 Тестирование

Прямой запуск на реальном Hermes:

```bash
# Базовые режимы
ai "тест"
echo "ошибка" | ai -e
ai -s "найти файлы"
ai --code "hello world"

# Pipe + args
echo "context" | ai "проверка"

# Telegram
ai "тест" --send

# Модели/провайдеры
ai -m deepseek/deepseek-chat "тест"
```

Проверять нужно:
1. Корректность ответа (содержательный, не ошибка)
2. Цветной вывод (`--no-color` отключает)
3. Обработку ошибок (Hermes не в PATH, таймаут)
4. Краевые случаи (пустой stdin, пустой args)

---

## 🗺 План расширения

```
Фаза 1: MVP             ✅ сделано (v0.5.0)
├── general / shell / explain / code
├── pipe / --send / --model
├── цветной вывод
├── -1..-9 / --verbose (детальность)
└── --fix-sessions / умные подсказки

Фаза 2: Улучшения       ✅ сделано (v0.7.0)
├── --chat (именованные сессии) ✅
│   ├── REPL: chat_repl() + slash-команды
│   ├── one-shot: ai --chat -n имя "вопрос"
│   ├── реестр: ~/.config/ai-shell/chats.json (имя → session_id)
│   └── контекст: hermes chat -q -Q [--resume <id>]
├── --copy (буфер обмена) ✅
│   ├── -c / --copy — копировать ответ в буфер
│   └── авто-определение: X11 → xclip, Wayland → wl-copy
├── zsh/bash completion ✅
│   ├── completions/ai.bash (статический, флаги + имена чатов)
│   └── completions/ai.zsh
└── --role (роли/персонажи)  ← отложено (работает через текст запроса)

Фаза 3: Интеграция
├── --file <файл> (контекст из файла)
├── shell-хуки (Alt+E)
└── --model / --provider на лету

Фаза 4: Pro
├── REPL-режим (ai repl)
├── история команд
├── роли в YAML-файлах
└── markdown-рендеринг
```

При переходе между фазами оценивай, не пора ли разбить `bin/ai`
на модули. Признаки:
- Файл > 800 строк
- Появляются дублирующиеся паттерны
- Хочется unit-тестов

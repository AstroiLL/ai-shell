# 📦 Установка и настройка ai-shell

## Быстрый старт

```bash
# У тебя уже есть Hermes? Проверь:
hermes --version

# Установи ai одной командой:
ln -sf ~/Sync/GPT/5-Progs/ai-shell/bin/ai ~/.local/bin/ai

# Проверь:
ai -V
# → ai-shell v0.5.0
```

## Подробная установка

### 1. Требования

- **Hermes Agent** — установлен и настроен
- **Python 3.12+** — идёт в комплекте с Hermes
- **Bash/Zsh** — любой современный shell

Проверка:

```bash
hermes doctor        # должен быть ✅ по всем пунктам
hermes status        # Gateway должен быть запущен (для --send)
python3 --version    # >= 3.12
```

### 2. Где лежит проект

По умолчанию:

```
~/Sync/GPT/5-Progs/ai-shell/
```

Если ты клонировал в другое место — скорректируй путь в команде ниже.

### 3. Установка скрипта

#### Способ A: симлинк (рекомендуется)

```bash
ln -sf ~/Sync/GPT/5-Progs/ai-shell/bin/ai ~/.local/bin/ai
```

Симлинк автоматически подхватывает обновления — правишь `bin/ai`
в проекте, и `~/.local/bin/ai` сразу обновляется.

#### Способ B: копия

```bash
cp ~/Sync/GPT/5-Progs/ai-shell/bin/ai ~/.local/bin/ai
```

### 4. Убедись, что ~/.local/bin в PATH

Проверь:

```bash
echo $PATH | grep --color=auto "$HOME/.local/bin"
```

Если не видно — добавь в `~/.bashrc` (или `~/.zshrc`):

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### 5. Проверка

```bash
ai -V                 # → ai-shell v0.5.0
ai "скажи привет"     # → Привет!
ai -s "echo test"     # → echo test
```

Готово к работе 🚀

---

## Настройка Telegram-отправки

Для `ai --send` нужен работающий Hermes Gateway с Telegram.

### Проверка

```bash
hermes gateway status
# Gateway Service: running ✓
# Telegram: connected ✓
```

### Если не работает

```bash
hermes gateway setup           # настроить платформы
hermes gateway install         # установить как сервис
hermes gateway start           # запустить
```

Подробнее: [документация Hermes Gateway](https://hermes-agent.nousresearch.com/docs/user-guide/messaging/)

---

## Использование

### Прямые вопросы

```bash
ai "как найти все jar файлы в системе"
ai "объясни разницу между git merge и git rebase"
ai "напиши docker-compose для PostgreSQL + Redis"
```

Результат — сразу в терминал. Можно пайпить дальше:

```bash
ai "сгенерируй 5 идей для pet-project" | grep -i python
```

### Shell-команды

```bash
ai -s "заархивировать логи за вчера в tar.gz"
ai -s "найти все файлы > 1GB и вывести размер"
```

Скрипт генерирует **одну** shell-команду, готовую к выполнению.
Запустить её можно с флагом `-r`:

```bash
ai -s -r "удалить все .tmp файлы в /tmp"
# 💻 find /tmp -name '*.tmp' -delete
#   Выполнить? [Y/n]
```

### Объяснение ошибок (explain)

```bash
# После неудачной команды
make 2>&1 | ai -e

# Из файла
ai -e < compile_errors.log

# Из пайпа цепочки
find / -type f -size +100M 2>/dev/null | ai -e
```

`ai -e` анализирует вывод и объясняет: что пошло не так, вероятная
причина, как исправить.

### Pipe с контекстом

```bash
# Контекст + вопрос
ps aux | ai "найди процессы java, отсортируй по памяти"
cat nginx.conf | ai "проверь конфиг на уязвимости"
git diff | ai "напиши commit message"
curl -s https://example.com | ai "о чём эта страница?"
```

Правило: `stdin` → контекст, `args` → вопрос/запрос.

### Генерация кода

```bash
ai --code "python-скрипт: скачать все PDF по списку URL"
ai --code "bash-функция: цветной логгер с timestamp"
```

Код возвращается в markdown-блоке с пояснением.

### Отправка в Telegram

```bash
# В домашний Telegram-канал
ai "погода на завтра" --send

# В конкретный чат
ai "релиз готов!" --send telegram:-1001234567890

# Только отправить (без вывода в терминал)
ai "сервер перезагружен" --send > /dev/null
```

Удобно для:
- Мониторинга деплоев
- Ночных отчётов
- Уведомлений из cron

### Продвинутые опции

```bash
# Сменить модель
ai -m anthropic/claude-sonnet-4 "напиши haiku про Linux"

# Сменить провайдера
ai -p openrouter "какой провайдер лучше для кода?"

# Отключить цвета
ai --no-color "просто текст, без ansi"

# Узнать версию
ai -V
```

---

## Примеры для повседневной работы

```bash
# DevOps / администрирование
ai -s "найти все PID слушающие на порту 3000"
journalctl -xe | ai -e
df -h | ai "какая файловая система забита больше всего?"

# Git
git log --oneline -10 | ai "напиши changelog"
git diff | ai "проверь, нет ли security-проблем"

# Кодинг
ai --code "fastapi endpoint: загрузка файла с валидацией размера"
cat requirements.txt | ai "есть ли устаревшие пакеты?"

# Разное
curl -s wttr.in/Moscow | ai "краткий прогноз"
ai "переведи на английский: нужно оптимизировать запросы к БД"
```

---

## Частые вопросы

### Не работает `--send`

Gateway не запущен:
```bash
hermes gateway status
hermes gateway start
```

### Скрипт обновился, а `~/.local/bin/ai` нет

Если использовал симлинк — просто обнови файлы в проекте.
Если копию — переустанови:
```bash
cp ~/Sync/GPT/5-Progs/ai-shell/bin/ai ~/.local/bin/ai
```

### Hermes не в PATH

```bash
export PATH="$HOME/.hermes/hermes-agent/venv/bin:$PATH"
# Добавь эту строку в ~/.bashrc, чтобы было постоянно
```

### Хочу свой режим

См. `DEVELOPER.md` в проекте — там пошаговая инструкция
по добавлению новых режимов.

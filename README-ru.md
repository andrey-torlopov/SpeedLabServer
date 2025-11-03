<p align="center">
  <img src="Docs/banner.png" alt="SpeedLab Server Logo" width="600"/>
</p>

<h1 align="center">SpeedLab Server</h1>

<p align="center">
Минимальный Vapor-сервер для тестирования скорости интернета и пингов.
</p>

<p align="center">
  <a href="https://swift.org">
    <img src="https://img.shields.io/badge/Swift-6.0+-orange.svg?logo=swift" alt="Swift 6.0+" />
  </a>
  <a href="https://swift.org/package-manager/">
    <img src="https://img.shields.io/badge/SPM-compatible-green.svg?logo=swift" alt="SPM" />
  </a>
  <img src="https://img.shields.io/badge/platform-macOS%2014%2B-orange.svg" alt="Platform" />
  <a href="https://vapor.codes">
    <img src="https://img.shields.io/badge/Vapor-4-blue.svg?logo=vapor" alt="Vapor 4" />
  </a>
  <a href="LICENSE">
    <img src="https://img.shields.io/badge/license-MIT-lightgrey.svg" alt="License" />
  </a>
  <img src="https://img.shields.io/badge/concurrency-async%2Fawait-purple.svg" alt="Concurrency" />
</p>

<p align="center">
  <a href="README.md">English version</a>
</p>

## Возможности

- **GET /ping** - RTT/проверка живости сервера
- **GET /download?size=N** - Скачивание синтетического файла указанного размера (для теста скорости загрузки)
- **POST /upload** - Загрузка файла на сервер (для теста скорости отдачи)
- **GET /files/{filename}** - Скачивание загруженного файла

## Требования

- macOS 14+
- Xcode 15+ (или Swift toolchain)
- Swift 5.10+/6.0

## Установка и запуск

### Сборка

```bash
swift build
```

### Запуск

```bash
swift run Run
```

Сервер запустится на `http://0.0.0.0:8080`

## API Endpoints

### 1. Ping (проверка живости)

```bash
curl http://127.0.0.1:8080/ping
```

**Ответ:**
```json
{
  "status": "pong"
}
```

### 2. Скачивание синтетического файла

Загружает файл указанного размера (в байтах) для тестирования скорости.

```bash
# Скачать 1 МБ
curl "http://127.0.0.1:8080/download?size=1048576" --output test.bin

# Скачать 10 МБ
curl "http://127.0.0.1:8080/download?size=10485760" --output test.bin
```

**Параметры:**
- `size` - размер файла в байтах (1..104857600, макс 100 МБ)
- По умолчанию: 131072 (128 КБ)

### 3. Загрузка файла на сервер

```bash
curl -F "file=@sample.txt" http://127.0.0.1:8080/upload
```

**Ответ:**
```json
{
  "filename": "sample.txt",
  "size": 1234,
  "url": "/files/sample.txt"
}
```

### 4. Скачивание загруженного файла

```bash
curl http://127.0.0.1:8080/files/sample.txt --output downloaded.txt
```

## Доступ из локальной сети

Сервер слушает на `0.0.0.0:8080`, что позволяет подключаться из других устройств в той же сети.

Узнайте IP-адрес вашего Mac:

```bash
ifconfig | grep "inet " | grep -v 127.0.0.1
```

Затем на другом устройстве используйте этот IP:

```bash
curl http://192.168.1.42:8080/ping
```

## Структура проекта

```
SpeedLabServer/
 ├─ Package.swift
 ├─ Sources/
 │  ├─ App/
 │  │  ├─ configure.swift
 │  │  ├─ routes.swift
 │  │  └─ Controllers/
 │  │     ├─ PingController.swift
 │  │     └─ FileController.swift
 │  └─ Run/
 │     └─ main.swift
 ├─ Storage/
 │  └─ uploads/
 └─ cleanup.sh          # Очистка временных файлов загрузок
```

## Обслуживание

### Очистка загруженных файлов

Для удаления временных тестовых файлов из папки `Storage/uploads/`:

```bash
./cleanup.sh
```

Этот скрипт удаляет все файлы кроме `.gitkeep`.

## Настройка

- Максимальный размер загружаемого файла: 50 МБ
- Максимальный размер синтетического файла для скачивания: 100 МБ
- Загруженные файлы хранятся в `Storage/uploads/`
- Заголовки `Cache-Control: no-store` предотвращают кеширование (для точных измерений скорости)

## Production заметки

Для использования в production рекомендуется:

1. Включить HTTPS (TLS)
2. Добавить аутентификацию для `/upload`
3. Настроить rate-limiting
4. Добавить ротацию/очистку загруженных файлов
5. Использовать reverse proxy (Nginx) для раздачи статических файлов
6. Добавить мониторинг и логирование
7. Настроить правила файрвола
8. Настроить правильную обработку ошибок и валидацию

## Безопасность

- Имена загружаемых файлов санитизируются для предотвращения атак directory traversal
- Дублирующиеся имена файлов обрабатываются добавлением временной метки
- Применяются ограничения на размер файлов
- Загруженные файлы не выполняются как код

## Лицензия

MIT License - подробности в файле LICENSE

## Участие в разработке

Приветствуются любые предложения! Не стесняйтесь создавать Pull Request.

## Автор

Создано SpaceZeroLab

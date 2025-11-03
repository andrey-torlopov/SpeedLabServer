import Vapor
import Foundation

public func configure(_ app: Application) throws {
    // Слушать на всех интерфейсах
    app.http.server.configuration.hostname = "0.0.0.0"
    app.http.server.configuration.port = 8080

    // Убедимся, что папка для загрузок существует
    let uploads = app.directory.workingDirectory + "Storage/uploads"
    try FileManager.default.createDirectory(atPath: uploads, withIntermediateDirectories: true, attributes: nil)

    try routes(app)

    // Вывод информации о запуске
    print("\n🚀 SpeedLab Server запущен!")
    print("📍 Адрес: http://0.0.0.0:8080")
    print("📂 Папка загрузок: \(uploads)")
    print("\nДоступные endpoints:")
    print("  GET  /ping                - Проверка RTT и живости сервера")
    print("  GET  /download?size=N     - Скачивание синтетического файла (макс 100 МБ)")
    print("  POST /upload              - Загрузка файла (макс 50 МБ)")
    print("  GET  /files/{filename}    - Скачивание загруженного файла")
    print("\nДля остановки нажмите Ctrl+C\n")
}

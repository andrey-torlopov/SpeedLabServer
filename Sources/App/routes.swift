import Vapor

func routes(_ app: Application) throws {
    try app.register(collection: PingController())
    try app.register(collection: FileController())

    // Раздача статических файлов из Storage/uploads по пути /files
    app.routes.defaultMaxBodySize = "50mb"
    app.get("files", "**") { req async throws -> Response in
        // files/<...> → читаем из Storage/uploads
        let relPath = req.parameters.getCatchall().joined(separator: "/")
        let fullPath = app.directory.workingDirectory + "Storage/uploads/" + relPath
        guard FileManager.default.fileExists(atPath: fullPath) else { throw Abort(.notFound) }
        return try await req.fileio.asyncStreamFile(at: fullPath)
    }
}

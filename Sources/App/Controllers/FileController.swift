import Vapor

struct FileController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.on(.POST, "upload", body: .collect(maxSize: "50mb"), use: upload)
        routes.get("download", use: syntheticDownload)
    }

    // POST /upload (multipart/form-data)
    // Поле: file (input name="file")
    func upload(_ req: Request) async throws -> Response {
        struct UploadPayload: Content {
            var file: File
        }
        let payload = try req.content.decode(UploadPayload.self)

        let uploadsDir = req.application.directory.workingDirectory + "Storage/uploads/"
        // Сохраняем под оригинальным именем с простейшей «де-конфликтовкой»
        let original = payload.file.filename
        let safeName = original.replacingOccurrences(of: "..", with: "_").replacingOccurrences(of: "/", with: "_")
        let dstURL = URL(fileURLWithPath: uploadsDir).appendingPathComponent(safeName)

        var finalURL = dstURL
        if FileManager.default.fileExists(atPath: finalURL.path) {
            let stamp = Int(Date().timeIntervalSince1970)
            finalURL = URL(fileURLWithPath: uploadsDir).appendingPathComponent("\(stamp)-\(safeName)")
        }

        try await req.fileio.writeFile(payload.file.data, at: finalURL.path)

        let publicURL = "/files/\(finalURL.lastPathComponent)"

        struct UploadResponse: Content {
            let filename: String
            let size: Int
            let url: String
        }

        var headers = HTTPHeaders()
        headers.replaceOrAdd(name: .cacheControl, value: "no-store")
        let res = Response(status: .created, headers: headers)
        try res.content.encode(UploadResponse(
            filename: finalURL.lastPathComponent,
            size: payload.file.data.readableBytes,
            url: publicURL
        ))
        return res
    }

    // GET /download?size=1048576
    // Отдать поток синтетических байт (0xAB) указанного размера
    func syntheticDownload(_ req: Request) throws -> Response {
        let size = (try? req.query.get(Int.self, at: "size")) ?? (128 * 1024)
        guard size > 0 && size <= 100 * 1024 * 1024 else { throw Abort(.badRequest, reason: "size must be 1..100 Mb") }

        var headers = HTTPHeaders()
        headers.replaceOrAdd(name: .cacheControl, value: "no-store")
        headers.replaceOrAdd(name: .contentLength, value: "\(size)")
        headers.replaceOrAdd(name: .contentType, value: "application/octet-stream")

        // Стриминг без выделения всего буфера в памяти
        let res = Response(status: .ok, headers: headers)
        res.body = .init(stream: { writer in
            // Пишем порциями по 64 КБ
            let chunkSize = 64 * 1024
            let fullChunks = size / chunkSize
            let tail = size % chunkSize
            let chunk = [UInt8](repeating: 0xAB, count: chunkSize)

            // helper: write Data → EventLoopFuture<Void>
            @Sendable func write(_ data: [UInt8]) -> EventLoopFuture<Void> {
                var buffer = ByteBufferAllocator().buffer(capacity: data.count)
                buffer.writeBytes(data)
                return writer.write(.buffer(buffer))
            }

            var fut = writer.eventLoop.makeSucceededVoidFuture()
            for _ in 0..<fullChunks {
                fut = fut.flatMap { write(chunk) }
            }
            if tail > 0 {
                let tailBytes = [UInt8](repeating: 0xAB, count: tail)
                fut = fut.flatMap { write(tailBytes) }
            }
            _ = fut.flatMap {
                writer.write(.end, promise: nil)
                return writer.eventLoop.makeSucceededVoidFuture()
            }
        })
        return res
    }
}

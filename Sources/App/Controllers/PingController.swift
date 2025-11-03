import Vapor

struct PingController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get("ping", use: ping)
    }

    func ping(_ req: Request) throws -> Response {
        struct PingResponse: Content {
            let status: String
        }

        var headers = HTTPHeaders()
        headers.replaceOrAdd(name: .cacheControl, value: "no-store, no-cache, must-revalidate")
        let res = Response(status: .ok, headers: headers)
        try res.content.encode(PingResponse(status: "pong"))
        return res
    }
}

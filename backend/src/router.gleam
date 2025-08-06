import gleam/http.{Get}
import tag
import web
import wisp.{type Request, type Response}

pub fn handle_request(req: Request) -> Response {
  use req <- web.middleware(req)

  case wisp.path_segments(req) {
    [] -> {
      use <- wisp.require_method(req, Get)
      wisp.ok()
      |> wisp.string_body("Hello world")
    }

    ["tags"] -> tag.get_all_endpoint(req)
    // curl -d '{"name":"pelle"}' -H "Content-Type: application/json" -X POST 127.0.0.1:4711/add_tag
    ["add_tag"] -> tag.add_endpoint(req)
    _ -> wisp.not_found()
  }
}

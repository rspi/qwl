import gleam/http.{Get}
import tag
import web
import wisp.{type Request, type Response}

pub fn handle_request(req: Request, context: web.Context) -> Response {
  use req <- web.middleware(req)

  case wisp.path_segments(req) {
    [] -> {
      use <- wisp.require_method(req, Get)
      wisp.ok()
      |> wisp.string_body("Hello world")
    }

    ["squirrel", "tags"] -> tag.get_all_with_squirrel_endpoint(req, context)
    ["squirrel", "add_tag"] -> tag.add_with_squirrel_endpoint(req, context)
    ["parrot", "tags"] -> tag.get_all_with_parrot_endpoint(req, context)
    ["parrot", "add_tag"] -> tag.add_with_parrot_endpoint(req, context)
    _ -> wisp.not_found()
  }
}

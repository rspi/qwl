import web
import wisp.{type Request, type Response}

pub fn handle_request(req: Request) -> Response {
  use req <- web.middleware(req)

  case wisp.path_segments(req) {
    [] ->
      wisp.ok()
      |> wisp.string_body("Hello world")

    _ -> wisp.not_found()
  }
}

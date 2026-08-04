import gleam/http.{Get}
import gleam/int
import web
import wisp.{type Request, type Response}
import workout_session

pub fn handle_request(req: Request, context: web.Context) -> Response {
  use req <- web.middleware(req)

  case wisp.path_segments(req) {
    [] -> {
      use <- wisp.require_method(req, Get)
      wisp.ok()
      |> wisp.string_body("Hello world")
    }

    ["workouts"] -> workout_session.get_all_endpoint(req, context)
    ["workouts", id_str] -> {
      case int.parse(id_str) {
        Ok(id) -> workout_session.get_by_id_endpoint(req, context, id)
        Error(_) -> wisp.bad_request("Invalid workout session ID format")
      }
    }
    _ -> wisp.not_found()
  }
}

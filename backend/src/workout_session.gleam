import gleam/http
import gleam/json
import gleam/list
import gleam/option.{type Option, None, Some}
import shared/workout_session.{
  type Location, Location, WorkoutSession, WorkoutSessionListItem,
  workout_session_list_item_to_json, workout_session_to_json,
}
import sql
import web
import wisp.{type Request, type Response}

fn build_location(
  name: Option(String),
  is_outdoor: Option(Bool),
) -> Option(Location) {
  case name, is_outdoor {
    Some(name), Some(is_outdoor) -> Some(Location(name:, is_outdoor:))
    _, _ -> None
  }
}

pub fn get_all_endpoint(req: Request, ctx: web.Context) -> Response {
  use <- wisp.require_method(req, http.Get)

  case sql.get_workout_sessions(ctx.db) {
    Ok(sessions_ret) -> {
      let sessions = {
        use row <- list.map(sessions_ret.rows)
        WorkoutSessionListItem(id: row.id, workout_date: row.workout_date)
      }

      sessions
      |> json.array(of: workout_session_list_item_to_json)
      |> json.to_string
      |> wisp.json_response(200)
    }
    Error(_) -> {
      wisp.log_error("Database error while fetching workout sessions")
      wisp.internal_server_error()
    }
  }
}

pub fn get_by_id_endpoint(req: Request, ctx: web.Context, id: Int) -> Response {
  use <- wisp.require_method(req, http.Get)

  case sql.get_workout_session_by_id(ctx.db, id) {
    Ok(session_ret) -> {
      case session_ret.rows {
        [] -> wisp.not_found()
        [row] -> {
          case
            sql.get_session_workout_types(ctx.db, id),
            sql.get_session_companions(ctx.db, id)
          {
            Ok(types_ret), Ok(companions_ret) -> {
              let session_types = list.map(types_ret.rows, fn(t) { t.name })
              let session_companions =
                list.map(companions_ret.rows, fn(c) { c.name })

              let session =
                WorkoutSession(
                  id: row.id,
                  workout_date: row.workout_date,
                  start_time: row.start_time,
                  end_time: row.end_time,
                  duration_minutes: row.duration_minutes,
                  effort: row.effort,
                  location: build_location(
                    row.location_name,
                    row.location_is_outdoor,
                  ),
                  feeling: row.feeling_name,
                  workout_types: session_types,
                  companions: session_companions,
                )

              session
              |> workout_session_to_json
              |> json.to_string
              |> wisp.json_response(200)
            }
            _, _ -> {
              wisp.log_error(
                "Database error while fetching workout session relations",
              )
              wisp.internal_server_error()
            }
          }
        }
        _ -> {
          wisp.log_error("Multiple sessions returned for ID")
          wisp.internal_server_error()
        }
      }
    }
    Error(_) -> {
      wisp.log_error("Database error while fetching workout session")
      wisp.internal_server_error()
    }
  }
}

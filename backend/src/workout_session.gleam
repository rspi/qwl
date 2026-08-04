import datetime_utils
import gleam/http
import gleam/json
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/time/calendar
import sql
import web
import wisp.{type Request, type Response}

pub type Location {
  Location(name: String, is_outdoor: Bool)
}

pub type WorkoutSession {
  WorkoutSession(
    id: Int,
    workout_date: calendar.Date,
    start_time: Option(calendar.TimeOfDay),
    end_time: Option(calendar.TimeOfDay),
    duration_minutes: Int,
    effort: Option(Int),
    location: Option(Location),
    feeling: Option(String),
    workout_types: List(String),
    companions: List(String),
  )
}

pub type WorkoutSessionListItem {
  WorkoutSessionListItem(id: Int, workout_date: calendar.Date)
}

fn build_location(
  name: Option(String),
  is_outdoor: Option(Bool),
) -> Option(Location) {
  case name, is_outdoor {
    Some(name), Some(is_outdoor) -> Some(Location(name:, is_outdoor:))
    _, _ -> None
  }
}

fn workout_session_list_item_to_json(session: WorkoutSessionListItem) -> json.Json {
  json.object([
    #("id", json.int(session.id)),
    #("workout_date", json.string(datetime_utils.date_to_string(session.workout_date))),
  ])
}

fn workout_session_to_json(session: WorkoutSession) -> json.Json {
  json.object([
    #("id", json.int(session.id)),
    #("workout_date", json.string(datetime_utils.date_to_string(session.workout_date))),
    #(
      "start_time",
      json.nullable(from: session.start_time, of: fn(t) {
        json.string(datetime_utils.time_to_string(t))
      }),
    ),
    #(
      "end_time",
      json.nullable(from: session.end_time, of: fn(t) {
        json.string(datetime_utils.time_to_string(t))
      }),
    ),
    #("duration_minutes", json.int(session.duration_minutes)),
    #("effort", json.nullable(from: session.effort, of: json.int)),
    #(
      "location",
      json.nullable(from: session.location, of: fn(l) {
        json.object([
          #("name", json.string(l.name)),
          #("is_outdoor", json.bool(l.is_outdoor)),
        ])
      }),
    ),
    #("feeling", json.nullable(from: session.feeling, of: json.string)),
    #("workout_types", json.array(session.workout_types, of: json.string)),
    #("companions", json.array(session.companions, of: json.string)),
  ])
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
              let session_companions = list.map(companions_ret.rows, fn(c) { c.name })

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
              wisp.log_error("Database error while fetching workout session relations")
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

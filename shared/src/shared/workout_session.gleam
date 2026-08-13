import shared/datetime_utils
import gleam/dynamic/decode
import gleam/json
import gleam/option.{type Option, None}
import gleam/time/calendar

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

// Encoders

pub fn workout_session_list_item_to_json(
  session: WorkoutSessionListItem,
) -> json.Json {
  json.object([
    #("id", json.int(session.id)),
    #(
      "workout_date",
      json.string(datetime_utils.date_to_string(session.workout_date)),
    ),
  ])
}

pub fn workout_session_to_json(session: WorkoutSession) -> json.Json {
  json.object([
    #("id", json.int(session.id)),
    #(
      "workout_date",
      json.string(datetime_utils.date_to_string(session.workout_date)),
    ),
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

// Decoders

pub fn date_decoder() -> decode.Decoder(calendar.Date) {
  use val <- decode.then(decode.string)
  case datetime_utils.string_to_date(val) {
    Ok(d) -> decode.success(d)
    Error(Nil) ->
      decode.failure(calendar.Date(0, calendar.January, 1), "calendar.Date")
  }
}

pub fn time_decoder() -> decode.Decoder(calendar.TimeOfDay) {
  use val <- decode.then(decode.string)
  case datetime_utils.string_to_time(val) {
    Ok(t) -> decode.success(t)
    Error(Nil) ->
      decode.failure(calendar.TimeOfDay(0, 0, 0, 0), "calendar.TimeOfDay")
  }
}

pub fn location_decoder() -> decode.Decoder(Location) {
  use name <- decode.field("name", decode.string)
  use is_outdoor <- decode.field("is_outdoor", decode.bool)
  decode.success(Location(name:, is_outdoor:))
}

pub fn workout_session_list_item_decoder() -> decode.Decoder(WorkoutSessionListItem) {
  use id <- decode.field("id", decode.int)
  use workout_date <- decode.field("workout_date", date_decoder())
  decode.success(WorkoutSessionListItem(id:, workout_date:))
}

pub fn workout_session_decoder() -> decode.Decoder(WorkoutSession) {
  use id <- decode.field("id", decode.int)
  use workout_date <- decode.field("workout_date", date_decoder())
  use start_time <- decode.optional_field(
    "start_time",
    None,
    decode.optional(time_decoder()),
  )
  use end_time <- decode.optional_field(
    "end_time",
    None,
    decode.optional(time_decoder()),
  )
  use duration_minutes <- decode.field("duration_minutes", decode.int)
  use effort <- decode.optional_field(
    "effort",
    None,
    decode.optional(decode.int),
  )
  use location <- decode.optional_field(
    "location",
    None,
    decode.optional(location_decoder()),
  )
  use feeling <- decode.optional_field(
    "feeling",
    None,
    decode.optional(decode.string),
  )
  use workout_types <- decode.field("workout_types", decode.list(decode.string))
  use companions <- decode.field("companions", decode.list(decode.string))

  decode.success(WorkoutSession(
    id:,
    workout_date:,
    start_time:,
    end_time:,
    duration_minutes:,
    effort:,
    location:,
    feeling:,
    workout_types:,
    companions:,
  ))
}

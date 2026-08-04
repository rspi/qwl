//// This module contains the code to run the sql queries defined in
//// `./src/sql`.
//// > 🐿️ This module was generated automatically using v4.7.0 of
//// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
////

import gleam/dynamic/decode
import gleam/option.{type Option}
import gleam/time/calendar.{type Date, type TimeOfDay}
import pog

/// A row you get from running the `get_session_companions` query
/// defined in `./src/sql/get_session_companions.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.7.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetSessionCompanionsRow {
  GetSessionCompanionsRow(name: String)
}

/// src/sql/get_session_companions.sql
///
/// > 🐿️ This function was generated automatically using v4.7.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_session_companions(
  db: pog.Connection,
  arg_1: Int,
) -> Result(pog.Returned(GetSessionCompanionsRow), pog.QueryError) {
  let decoder = {
    use name <- decode.field(0, decode.string)
    decode.success(GetSessionCompanionsRow(name:))
  }

  "-- src/sql/get_session_companions.sql
SELECT 
  c.name
FROM workout_session_companion wsc
JOIN companion c ON wsc.companion_id = c.id
WHERE wsc.workout_session_id = $1;
"
  |> pog.query
  |> pog.parameter(pog.int(arg_1))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `get_session_workout_types` query
/// defined in `./src/sql/get_session_workout_types.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.7.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetSessionWorkoutTypesRow {
  GetSessionWorkoutTypesRow(name: String)
}

/// src/sql/get_session_workout_types.sql
///
/// > 🐿️ This function was generated automatically using v4.7.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_session_workout_types(
  db: pog.Connection,
  arg_1: Int,
) -> Result(pog.Returned(GetSessionWorkoutTypesRow), pog.QueryError) {
  let decoder = {
    use name <- decode.field(0, decode.string)
    decode.success(GetSessionWorkoutTypesRow(name:))
  }

  "-- src/sql/get_session_workout_types.sql
SELECT 
  wt.name
FROM workout_session_workout_type wswt
JOIN workout_type wt ON wswt.workout_type_id = wt.id
WHERE wswt.workout_session_id = $1;
"
  |> pog.query
  |> pog.parameter(pog.int(arg_1))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `get_workout_session_by_id` query
/// defined in `./src/sql/get_workout_session_by_id.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.7.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetWorkoutSessionByIdRow {
  GetWorkoutSessionByIdRow(
    id: Int,
    workout_date: Date,
    start_time: Option(TimeOfDay),
    end_time: Option(TimeOfDay),
    duration_minutes: Int,
    effort: Option(Int),
    location_name: Option(String),
    location_is_outdoor: Option(Bool),
    feeling_name: Option(String),
  )
}

/// src/sql/get_workout_session_by_id.sql
///
/// > 🐿️ This function was generated automatically using v4.7.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_workout_session_by_id(
  db: pog.Connection,
  arg_1: Int,
) -> Result(pog.Returned(GetWorkoutSessionByIdRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, decode.int)
    use workout_date <- decode.field(1, pog.calendar_date_decoder())
    use start_time <- decode.field(
      2,
      decode.optional(pog.calendar_time_of_day_decoder()),
    )
    use end_time <- decode.field(
      3,
      decode.optional(pog.calendar_time_of_day_decoder()),
    )
    use duration_minutes <- decode.field(4, decode.int)
    use effort <- decode.field(5, decode.optional(decode.int))
    use location_name <- decode.field(6, decode.optional(decode.string))
    use location_is_outdoor <- decode.field(7, decode.optional(decode.bool))
    use feeling_name <- decode.field(8, decode.optional(decode.string))
    decode.success(GetWorkoutSessionByIdRow(
      id:,
      workout_date:,
      start_time:,
      end_time:,
      duration_minutes:,
      effort:,
      location_name:,
      location_is_outdoor:,
      feeling_name:,
    ))
  }

  "-- src/sql/get_workout_session_by_id.sql
SELECT 
  ws.id,
  ws.workout_date,
  ws.start_time,
  ws.end_time,
  ws.duration_minutes,
  ws.effort,
  l.name AS location_name,
  l.is_outdoor AS location_is_outdoor,
  f.name AS feeling_name
FROM workout_session ws
LEFT JOIN location l ON ws.location_id = l.id
LEFT JOIN feeling f ON ws.feeling_id = f.id
WHERE ws.id = $1;
"
  |> pog.query
  |> pog.parameter(pog.int(arg_1))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `get_workout_sessions` query
/// defined in `./src/sql/get_workout_sessions.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.7.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetWorkoutSessionsRow {
  GetWorkoutSessionsRow(id: Int, workout_date: Date)
}

/// src/sql/get_workout_sessions.sql
///
/// > 🐿️ This function was generated automatically using v4.7.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_workout_sessions(
  db: pog.Connection,
) -> Result(pog.Returned(GetWorkoutSessionsRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, decode.int)
    use workout_date <- decode.field(1, pog.calendar_date_decoder())
    decode.success(GetWorkoutSessionsRow(id:, workout_date:))
  }

  "-- src/sql/get_workout_sessions.sql
SELECT 
  id,
  workout_date
FROM workout_session
ORDER BY workout_date DESC;
"
  |> pog.query
  |> pog.returning(decoder)
  |> pog.execute(db)
}

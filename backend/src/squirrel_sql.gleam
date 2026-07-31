//// This module contains the code to run the sql queries defined in
//// `./src/sql`.
//// > 🐿️ This module was generated automatically using v4.7.0 of
//// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
////

import gleam/dynamic/decode
import pog

/// A row you get from running the `add_tag` query
/// defined in `./src/sql/add_tag.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.7.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type AddTagRow {
  AddTagRow(id: Int, name: String)
}

/// name: AddTag :one
///
/// > 🐿️ This function was generated automatically using v4.7.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn add_tag(
  db: pog.Connection,
  arg_1: String,
) -> Result(pog.Returned(AddTagRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, decode.int)
    use name <- decode.field(1, decode.string)
    decode.success(AddTagRow(id:, name:))
  }

  "-- name: AddTag :one
insert into tag (name) values ($1) returning id, name;
"
  |> pog.query
  |> pog.parameter(pog.text(arg_1))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `get_all_tags` query
/// defined in `./src/sql/get_all_tags.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.7.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetAllTagsRow {
  GetAllTagsRow(id: Int, name: String)
}

/// name: GetAllTags :many
///
/// > 🐿️ This function was generated automatically using v4.7.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_all_tags(
  db: pog.Connection,
) -> Result(pog.Returned(GetAllTagsRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, decode.int)
    use name <- decode.field(1, decode.string)
    decode.success(GetAllTagsRow(id:, name:))
  }

  "-- name: GetAllTags :many
select id, name from tag;
"
  |> pog.query
  |> pog.returning(decoder)
  |> pog.execute(db)
}

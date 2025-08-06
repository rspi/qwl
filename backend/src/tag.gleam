import gleam/dynamic/decode
import gleam/http
import gleam/json
import gleam/string_tree
import wisp.{type Request, type Response}

pub type Tag {
  Tag(name: String)
}

fn tag_decoder() -> decode.Decoder(Tag) {
  use name <- decode.field("name", decode.string)
  decode.success(Tag(name:))
}

fn to_json(tag: Tag) -> json.Json {
  json.object([#("name", json.string(tag.name))])
}

pub fn add_endpoint(req: Request) -> Response {
  use <- wisp.require_method(req, http.Post)
  use json <- wisp.require_json(req)
  let result = decode.run(json, tag_decoder())

  case result {
    Error(_) -> wisp.bad_request()
    Ok(tag) -> {
      wisp.log_warning("Missing implementation to save tag: " <> tag.name)
      wisp.ok()
    }
  }
}

pub fn get_all_endpoint(req: Request) -> Response {
  use <- wisp.require_method(req, http.Get)
  [Tag(name: "TestTag")]
  |> json.array(to_json)
  |> json.to_string
  |> string_tree.from_string
  |> wisp.json_response(200)
}

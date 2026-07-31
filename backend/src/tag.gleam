import gleam/dynamic/decode
import gleam/http
import gleam/json
import gleam/list
import gleam/string
import parrot/dev
import parrot_sql
import pog
import squirrel_sql
import web
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

// --- Squirrel Endpoints ---

pub fn add_with_squirrel_endpoint(req: Request, ctx: web.Context) -> Response {
  use <- wisp.require_method(req, http.Post)
  use json <- wisp.require_json(req)
  let result = decode.run(json, tag_decoder())

  case result {
    Error(_) -> wisp.bad_request("invalid format")
    Ok(tag) -> {
      case squirrel_sql.add_tag(ctx.db.data, tag.name) {
        Ok(returned) -> {
          case returned.rows {
            [row, ..] -> {
              Tag(name: row.name)
              |> to_json
              |> json.to_string
              |> wisp.json_response(201)
            }
            [] -> wisp.internal_server_error()
          }
        }
        Error(err) -> {
          wisp.log_error("Squirrel query failed: " <> string.inspect(err))
          wisp.internal_server_error()
        }
      }
    }
  }
}

pub fn get_all_with_squirrel_endpoint(req: Request, ctx: web.Context) -> Response {
  use <- wisp.require_method(req, http.Get)
  case squirrel_sql.get_all_tags(ctx.db.data) {
    Ok(returned) -> {
      returned.rows
      |> list.map(fn(row) { Tag(name: row.name) })
      |> json.array(to_json)
      |> json.to_string
      |> wisp.json_response(200)
    }
    Error(err) -> {
      wisp.log_error("Squirrel query failed: " <> string.inspect(err))
      wisp.internal_server_error()
    }
  }
}

// --- Parrot Endpoints ---

fn parrot_to_pog_param(param: dev.Param) -> pog.Value {
  case param {
    dev.ParamInt(val) -> pog.int(val)
    dev.ParamBool(val) -> pog.bool(val)
    dev.ParamFloat(val) -> pog.float(val)
    dev.ParamString(val) -> pog.text(val)
    _ -> pog.null()
  }
}

pub fn add_with_parrot_endpoint(req: Request, ctx: web.Context) -> Response {
  use <- wisp.require_method(req, http.Post)
  use json <- wisp.require_json(req)
  let result = decode.run(json, tag_decoder())

  case result {
    Error(_) -> wisp.bad_request("invalid format")
    Ok(tag) -> {
      let #(sql, params, decoder) = parrot_sql.add_tag(name: tag.name)
      
      let query = pog.query(sql) |> pog.returning(decoder)
      let query = list.fold(params, query, fn(q, p) {
        pog.parameter(q, parrot_to_pog_param(p))
      })
      
      case pog.execute(query, ctx.db.data) {
        Ok(returned) -> {
          case returned.rows {
            [row, ..] -> {
              Tag(name: row.name)
              |> to_json
              |> json.to_string
              |> wisp.json_response(201)
            }
            [] -> wisp.internal_server_error()
          }
        }
        Error(err) -> {
          wisp.log_error("Parrot query failed: " <> string.inspect(err))
          wisp.internal_server_error()
        }
      }
    }
  }
}

pub fn get_all_with_parrot_endpoint(req: Request, ctx: web.Context) -> Response {
  use <- wisp.require_method(req, http.Get)
  let #(sql, params, decoder) = parrot_sql.get_all_tags()
  
  let query = pog.query(sql) |> pog.returning(decoder)
  let query = list.fold(params, query, fn(q, p) {
    pog.parameter(q, parrot_to_pog_param(p))
  })
  
  case pog.execute(query, ctx.db.data) {
    Ok(returned) -> {
      returned.rows
      |> list.map(fn(row) { Tag(name: row.name) })
      |> json.array(to_json)
      |> json.to_string
      |> wisp.json_response(200)
    }
    Error(err) -> {
      wisp.log_error("Parrot query failed: " <> string.inspect(err))
      wisp.internal_server_error()
    }
  }
}

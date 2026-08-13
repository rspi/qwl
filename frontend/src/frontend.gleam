import gleam/dynamic/decode
import gleam/json
import gleam/list
import gleam/string
import lustre
import lustre/attribute
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import shared/datetime_utils
import shared/workout_session.{
  type WorkoutSessionListItem, workout_session_list_item_decoder,
}

// 1. MAIN ENTRYPOINT ----------------------------------------------------------

pub fn main() {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)
  Nil
}

// 2. MODEL --------------------------------------------------------------------

pub type Model {
  Model(sessions: List(WorkoutSessionListItem), status: Status)
}

pub type Status {
  Idle
  Loading
  Success
  Failure(String)
}

fn init(_flags) -> #(Model, Effect(Msg)) {
  #(
    Model(sessions: [], status: Loading),
    fetch_workouts_effect(ApiReturnedWorkouts),
  )
}

// 3. MESSAGES & UPDATE --------------------------------------------------------

pub type Msg {
  FetchWorkouts
  ApiReturnedWorkouts(Result(String, String))
}

fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    FetchWorkouts -> #(
      Model(..model, status: Loading),
      fetch_workouts_effect(ApiReturnedWorkouts),
    )

    ApiReturnedWorkouts(Ok(json_str)) -> {
      let decoder = decode.list(of: workout_session_list_item_decoder())
      case json.parse(from: json_str, using: decoder) {
        Ok(items) -> {
          #(Model(sessions: items, status: Success), effect.none())
        }
        Error(err) -> {
          #(
            Model(
              ..model,
              status: Failure(
                "Failed to parse JSON response: " <> string.inspect(err),
              ),
            ),
            effect.none(),
          )
        }
      }
    }

    ApiReturnedWorkouts(Error(err)) -> {
      #(
        Model(..model, status: Failure("Network or API error: " <> err)),
        effect.none(),
      )
    }
  }
}

// 4. EFFECTS & FFI ------------------------------------------------------------

@external(javascript, "./fetch_ffi.mjs", "fetch_workouts")
pub fn fetch_workouts(
  on_success: fn(String) -> Nil,
  on_error: fn(String) -> Nil,
) -> Nil

pub fn fetch_workouts_effect(
  on_result: fn(Result(String, String)) -> msg,
) -> Effect(msg) {
  use dispatch <- effect.from
  fetch_workouts(
    fn(text) { dispatch(on_result(Ok(text))) },
    fn(err) { dispatch(on_result(Error(err))) },
  )
}

// 5. VIEW ---------------------------------------------------------------------

fn view(model: Model) -> Element(Msg) {
  html.div(
    [
      attribute.styles([
        #("font-family", "sans-serif"),
        #("max-width", "800px"),
        #("margin", "0 auto"),
        #("padding", "20px"),
      ]),
    ],
    [
      html.h1([], [html.text("Workout Sessions")]),
      html.button(
        [
          event.on_click(FetchWorkouts),
          attribute.disabled(model.status == Loading),
          attribute.styles([
            #("padding", "8px 16px"),
            #("font-size", "14px"),
            #("cursor", "pointer"),
            #("background-color", "#007bff"),
            #("color", "white"),
            #("border", "none"),
            #("border-radius", "4px"),
            #("margin-bottom", "20px"),
          ]),
        ],
        [html.text("Refresh list")],
      ),
      case model.status {
        Idle -> html.p([], [html.text("No data fetched yet.")])
        Loading -> html.p([], [html.text("Loading workout sessions...")])
        Failure(err) ->
          html.p([attribute.styles([#("color", "red")])], [
            html.text("Error: " <> err),
          ])
        Success -> {
          case model.sessions {
            [] -> html.p([], [html.text("No workout sessions found.")])
            items -> {
              html.ul(
                [
                  attribute.styles([
                    #("list-style-type", "none"),
                    #("padding", "0"),
                  ]),
                ],
                list.map(items, fn(session) {
                  html.li(
                    [
                      attribute.styles([
                        #("padding", "12px"),
                        #("margin-bottom", "8px"),
                        #("border", "1px solid #dee2e6"),
                        #("border-radius", "4px"),
                        #("background-color", "#f8f9fa"),
                      ]),
                    ],
                    [
                      html.strong(
                        [],
                        [
                          html.text(
                            "Session #" <> string.inspect(session.id),
                          ),
                        ],
                      ),
                      html.span(
                        [attribute.styles([#("margin-left", "15px")])],
                        [
                          html.text(
                            "Date: "
                            <> datetime_utils.date_to_string(
                              session.workout_date,
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                }),
              )
            }
          }
        }
      },
    ],
  )
}

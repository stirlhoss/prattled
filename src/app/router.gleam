import wisp.{type Request, type Response}
import gleam/string_builder
import app/web

/// The HTTP request handler- your application!
/// 
pub fn handle_request(req: Request) -> Response {
  // Apply the middleware stack for this request/response.
  use _req <- web.middleware(req)

    // Wisp doesn't have a special router abstraction, instead we recommend using
  // regular old pattern matching. This is faster than a router, is type safe,
  // and means you don't have to learn or be limited by a special DSL.
  //
  case wisp.path_segments(req) {
    // This matches `/`.
    [] -> home_page(req)

    // This matches `/comments`.
    ["comments"] -> comments(req)

    // This matches `/comments/:id`.
    // The `id` segment is bound to a variable and passed to the handler.
    ["comments", id] -> show_comment(req, id)

    // This matches all other paths.
    _ -> wisp.not_found()
  }
}



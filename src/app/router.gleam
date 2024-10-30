import app/web
import gleam/http.{Get, Post}
import gleam/string_builder
import gleam/list
import gleam/result
import wisp.{type Request, type Response}

/// The HTTP request handler- your application!
/// 
pub fn handle_request(req: Request) -> Response {
  // Apply the middleware stack for this request/response.
  use req <- web.middleware(req)

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

fn home_page(req: Request) -> Response {
  case req.method {
    Get -> show_form()
    Post -> handle_form_submission(req)
    _ -> wisp.method_not_allowed(allowed: [Get, Post])
  }
  // The home page can only be accessed via GET requests, so this middleware is
  // used to return a 405: Method Not Allowed response for all other methods.
  // use <- wisp.require_method(req, Get)

  // let html = string_builder.from_string("")
  // wisp.ok()
  // |> wisp.html_body(html)
}

fn show_form() -> Response {
  let html =
    string_builder.from_string(
      "<h1>Prattle on...</h1>
       <form method='post'>
        <label>Title:
          <input type='text' name='title'>
        </label>
        <label>Name:
          <input type='text' name='name'>
        </label>
        <input type='submit' value='Submit'>
      </form>",
    )
  wisp.ok()
  |> wisp.html_body(html)
}

pub fn handle_form_submission(req: Request) -> Response {
  // This middleware parses a `wisp.FormData` from the request body.
  // It returns an error response if the body is not valid form data, or
  // if the content-type is not `application/x-www-form-urlencoded` or
  // `multipart/form-data`, or if the body is too large.
  use formdata <- wisp.require_form(req)

  // The list and result module are used here to extract the values from the
  // form data.
  // Alternatively you could also pattern match on the list of values (they are
  // sorted into alphabetical order), or use a HTML form library.
  let result = {
    use title <- result.try(list.key_find(formdata.values, "title"))
    use name <- result.try(list.key_find(formdata.values, "name"))
    let greeting =
      "Hi, " <> wisp.escape_html(title) <> " " <> wisp.escape_html(name) <> "!"
    Ok(greeting)
  }

  // An appropriate response is returned depending on whether the form data
  // could be successfully handled or not.
  case result {
    Ok(content) -> {
      wisp.ok()
      |> wisp.html_body(string_builder.from_string(content))
    }
    Error(_) -> {
      wisp.bad_request()
    }
  }
}

fn comments(req: Request) -> Response {
  case req.method {
    Get -> list_comments()
    Post -> create_comment(req)
    _ -> wisp.method_not_allowed([Get, Post])
  }
}

fn list_comments() -> Response {
  // In a later example we'll show how to read from a database.
  let html = string_builder.from_string("Comments!")
  wisp.ok()
  |> wisp.html_body(html)
}

fn create_comment(_req: Request) -> Response {
  let html = string_builder.from_string("Created")
  wisp.created()
  |> wisp.html_body(html)
}

fn show_comment(req: Request, id: String) -> Response {
  use <- wisp.require_method(req, Get)

  // The `id` path parameter has been passed to this function, so we could use
  // it to look up a comment in a database.
  // For now we'll just include in the response body.
  let html = string_builder.from_string("Comment with id " <> id)
  wisp.ok()
  |> wisp.html_body(html)
}

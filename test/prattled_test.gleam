import app/router
import gleam/string
import gleeunit
import gleeunit/should
import wisp/testing

pub fn main() {
  gleeunit.main()
}

pub fn get_home_page_test() {
  let request = testing.get("/", [])
  let response = router.handle_request(request)

  response.status
  |> should.equal(200)

  response.headers
  |> should.equal([#("content-type", "text/html; charset=utf-8")])

  response
  |> testing.string_body
  |> string.contains("Prattle on...")
  |> should.equal(True)
}

pub fn submit_wrong_content_type_test() {
  let response = router.handle_request(testing.post("/", [], ""))

  response.status
  |> should.equal(415)

  response.headers
  |> should.equal([
    #("accept", "application/x-www-form-urlencoded, multipart/form-data"),
  ])
}

pub fn submit_missing_parameters_test() {
  // The `METHOD_form` functions are used to create a request with a
  // `x-www-form-urlencoded` body, with the appropriate `content-type` header.
  let response =
    testing.post_form("/", [], [])
    |> router.handle_request()

  response.status
  |> should.equal(400)
}

pub fn submit_successful_test() {
  let response =
    testing.post_form("/", [], [#("title", "Captain"), #("name", "Caveman")])
    |> router.handle_request()

  response.status
  |> should.equal(200)

  response.headers
  |> should.equal([#("content-type", "text/html; charset=utf-8")])

  response
  |> testing.string_body
  |> should.equal("Hi, Captain Caveman!")
}

pub fn page_not_found_test() {
  let request = testing.get("/nothing-here", [])
  let response = router.handle_request(request)
  response.status
  |> should.equal(404)
}

pub fn get_comments_test() {
  let request = testing.get("/comments", [])
  let response = router.handle_request(request)
  response.status
  |> should.equal(200)
}

pub fn post_comments_test() {
  let request = testing.post("/comments", [], "")
  let response = router.handle_request(request)
  response.status
  |> should.equal(201)
}

pub fn delete_comments_test() {
  let request = testing.delete("/comments", [], "")
  let response = router.handle_request(request)
  response.status
  |> should.equal(405)
}

pub fn get_comment_test() {
  let request = testing.get("/comments/123", [])
  let response = router.handle_request(request)
  response.status
  |> should.equal(200)
  response
  |> testing.string_body
  |> should.equal("Comment with id 123")
}

pub fn delete_comment_test() {
  let request = testing.delete("/comments/123", [], "")
  let response = router.handle_request(request)
  response.status
  |> should.equal(405)
}

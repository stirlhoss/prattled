import app/error.{type AppError}
import app/web.{type Context}
import gleam/dict
import gleam/dynamic.{type Dynamic}
import gleam/http.{Get, Post}
import gleam/json
import gleam/result
import sqlight
import wisp.{type Request, type Response}

pub type Word {
  Word(id: Int, word: String)
}

pub type Definition {
  Definition(
    id: Int,
    author: String,
    definition: String,
    word_count: Int,
    word_id: Int,
  )
}

/// Decode an item from a database row.
///
pub fn word_row_decoder() -> dynamic.Decoder(Word) {
  dynamic.decode2(
    Word,
    dynamic.element(0, dynamic.int),
    dynamic.element(1, dynamic.string),
  )
}

// This request handler is used for requests to `/:letter/:word`.
//

// pub fn one(req: Request, ctx: Context, letter: String, word: String) -> Response {
//   // Dispatch to the appropriate handler based on the HTTP method.
//   case req.method {
//     Get -> read_from_database(ctx, letter, word)
//     _ -> Error(error.MethodNotAllowed)
//   }
// }

// pub fn read_word(ctx: Context, letter: String, word: String) -> Response {
//   let result = {
//     // Read the person with the given id from the database.
//     use word <- try(read_from_database(ctx.db, letter, word))

//     // Construct a JSON payload with the person's details.
//     Ok(
//       json.to_string_builder(
//         json.object([
//           #("id", json.string(word.id)),
//           #("name", json.string(person.name)),
//           #("favourite-colour", json.string(person.favourite_colour)),
//         ]),
//       ),
//     )
//   }
//   // Return an appropriate response.
//   case result {
//     Ok(json) -> wisp.json_response(json, 200)
//     Error(Nil) -> wisp.not_found()
//   }
// }

// /// Save a word to the database and return the id of the newly created record.
// pub fn save_to_database(
//   db: sqlight.Connection,
//   word: Word,
// ) -> Result(String, Nil) {
//   // In a real application you might use a database client with some SQL here.
//   // Instead we create a simple dict and save that.
//   let data =
//     dict.from_list([#("word", word.word), #("defintions", word.definitions)])
//   sqlight.insert(db, data)
// }

pub fn read_from_database(
  ctx: Context,
  letter: String,
  word: String,
) -> Result(Word, AppError) {
  // In a real application you might use a database client with some SQL here.
  let sql =
    "
  select
    *
  from
    words
  where
    words.word = ?1
    "
  let assert Ok(rows) =
    sqlight.query(
      sql,
      on: ctx.db,
      with: [sqlight.text(word)],
      expecting: word_row_decoder(),
    )

  case rows {
    [word] -> Ok(word)
    _ -> Error(error.NotFound)
  }
}

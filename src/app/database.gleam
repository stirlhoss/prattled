import app/error.{type AppError}
import gleam/result
import sqlight

pub type Connection =
  sqlight.Connection

pub fn with_connection(name: String, f: fn(sqlight.Connection) -> a) -> a {
  use db <- sqlight.with_connection(name)
  let assert Ok(_) = sqlight.exec("pragma foreign_keys = on;", db)
  f(db)
}

pub fn migrate_schema(db: sqlight.Connection) -> Result(Nil, AppError) {
  sqlight.exec(
    "
    CREATE TABLE IF NOT EXISTS `word` (
        `id` integer primary key autoincrement NOT NULL UNIQUE,
        `word` TEXT NOT NULL UNIQUE,
    ) strict;

    CREATE TABLE IF NOT EXISTS `definitions` (
        `id` integer primary key autoincrement NOT NULL UNIQUE,
        `definition` TEXT NOT NULL,
        `word_id` INTEGER NOT NULL,
        `word_count` INTEGER NOT NULL,
        `author` TEXT NOT NULL,
        `time_stamp` TEXT NOT NULL default current_timestamp,
    FOREIGN KEY(`word_id`) REFERENCES `Word`(`id`)
    );",
    db,
  )
  |> result.map_error(error.SqlightError)
}

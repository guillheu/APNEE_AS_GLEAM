import gleam/list
import gleam/string

pub type TokenizerError {
  UnexpectedToken(found: String)
  AffectationWithoutPriorToken
}

pub fn run(from: String) -> List(String) {
  let #(last_word, tokenized) =
    from
    |> string.to_graphemes
    |> list.fold(#("", []), tokenize)

  [last_word, ..tokenized]
  |> list.filter_map(fn(token) {
    case token {
      "" -> Error(Nil)
      _ -> Ok(string.reverse(token))
    }
  })
  |> list.reverse
}

fn tokenize(
  acc: #(String, List(String)),
  next_character: String,
) -> #(String, List(String)) {
  let #(current_token, found_tokens) = acc
  case next_character {
    " " | "\n" | "\t" -> acc
    ";" | "=" | "|" | "+" | "-" | "*" | "/" | "^" | "(" | ")" -> #("", [
      next_character,
      current_token,
      ..found_tokens
    ])

    _ -> #(next_character <> current_token, found_tokens)
  }
}

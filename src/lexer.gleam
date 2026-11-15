import gleam/float
import gleam/int
import gleam/list
import gleam/result

pub type LexerError {
  AffectationWithoutVariable
}

pub type Token {
  Assignment(variable_name: String)
  Semicolon
  Plus
  Minus
  Star
  Slash
  Power
  Variable(variable_name: String)
  Value(value: Float)
  OpeningParenthesis
  ClosingParenthesis
  VerticalBar
}

pub fn run(tokens: List(String)) -> Result(List(Token), LexerError) {
  use tokenized_list <- result.map(list.try_fold(tokens, [], tokenize))
  list.reverse(tokenized_list)
}

fn tokenize(
  tokens: List(Token),
  next_token: String,
) -> Result(List(Token), LexerError) {
  case next_token {
    "=" ->
      case tokens {
        [Variable(variable_name), ..rest] ->
          Ok([Assignment(variable_name:), ..rest])
        _ -> Error(AffectationWithoutVariable)
      }
    ";" -> Ok([Semicolon, ..tokens])
    "+" -> Ok([Plus, ..tokens])
    "-" -> Ok([Minus, ..tokens])
    "*" -> Ok([Star, ..tokens])
    "/" -> Ok([Slash, ..tokens])
    "^" -> Ok([Power, ..tokens])
    "(" -> Ok([OpeningParenthesis, ..tokens])
    ")" -> Ok([ClosingParenthesis, ..tokens])
    "|" -> Ok([VerticalBar, ..tokens])
    _ ->
      case float.parse(next_token) {
        Ok(decoded_float) -> Ok([Value(decoded_float), ..tokens])
        Error(_) ->
          case int.parse(next_token) {
            Ok(decoded_int) ->
              Ok([Value(decoded_int |> int.to_float), ..tokens])
            Error(_) -> Ok([Variable(variable_name: next_token), ..tokens])
          }
      }
  }
}

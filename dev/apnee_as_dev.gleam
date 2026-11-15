import gleam/float
import gleam/io
import gleam/list
import gleam/result
import grammar
import lexer
import tokenizer

pub fn main() {
  let string = "a =12"
  let tokenized = tokenizer.run(string)
  io.println("TOKENS: ")
  list.each(tokenized, fn(token) { io.print(token <> " | ") })
  use r <- result.map(lexer.run(tokenized))
  io.println("\nLEXER'D:")
  list.each(r, fn(token) { echo token })
  io.println("\n\nRunning syntactic analysis\n")
  case grammar.evaluate(r) {
    Ok(grammar.Assignment(value, to_variable)) -> {
      "Assignment : " <> to_variable <> " = " <> float.to_string(value)
    }
    Ok(grammar.Expression(value)) -> {
      "Expression result: " <> float.to_string(value)
    }
    Error(_) -> "syntax error"
  }
  |> io.println
}

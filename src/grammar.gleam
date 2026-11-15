import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string

import lexer.{
  type Token, Assignment as AssignmentT, ClosingParenthesis, Minus,
  OpeningParenthesis, Plus, Power, Semicolon, Slash, Star, Value, Variable,
  VerticalBar,
}

pub type EvaluationResult {
  Assignment(value: Float, variable_name: String)
  Expression(value: Float)
}

pub fn evaluate(word: List(Token)) -> Result(EvaluationResult, Nil) {
  use #(results, _) <- result.map(run(Sp, word, None))
  let assert Some(r) = results
  r
}

fn run(
  symbol: NonTerminal,
  tokens: List(Token),
  previous_evaluated_value: Option(EvaluationResult),
) -> Result(#(Option(EvaluationResult), List(Token)), Nil) {
  case symbol, list.first(tokens), previous_evaluated_value {
    Sp, Ok(AssignmentT(_)), None
    | Sp, Ok(Variable(_)), None
    | Sp, Ok(Value(_)), None
    | Sp, Ok(OpeningParenthesis), None
    -> one(tokens)
    A, Ok(AssignmentT(_)), None -> four(tokens)
    A, Ok(Variable(_)), None
    | A, Ok(Value(_)), None
    | A, Ok(OpeningParenthesis), None
    -> five(tokens)
    E, Ok(Variable(_)), None
    | E, Ok(Value(_)), None
    | E, Ok(OpeningParenthesis), None
    -> six(tokens)
    Ep, Ok(Semicolon), eval_option -> nine(tokens, eval_option)
    T, Ok(Variable(_)), None
    | T, Ok(Value(_)), None
    | T, Ok(OpeningParenthesis), None
    -> ten(tokens)
    Tp, Ok(Semicolon), eval_option -> thirteen(tokens, eval_option)
    P, Ok(Variable(_)), None
    | P, Ok(Value(_)), None
    | P, Ok(OpeningParenthesis), None
    -> fourteen(tokens)
    Pp, Ok(Semicolon), eval_option -> sixteen(tokens, eval_option)
    F, Ok(Value(_)), None -> eighteen(tokens)
    S, Error(_), eval_option -> three(tokens, eval_option)

    // Everything else is a syntax error
    _, _, _ -> Error(Nil)
  }
}

// ------------------------ SYMBOLS ---------------------------------

pub type NonTerminal {
  Sp
  S
  A
  E
  Ep
  T
  Tp
  P
  Pp
  F
}

//------------------------- RULES -----------------------------------

// S' -> A;S
fn one(
  tokens: List(Token),
) -> Result(#(Option(EvaluationResult), List(Token)), Nil) {
  use r <- result.try(run(A, tokens, None))
  let #(eval_a, tokens) = r
  case tokens {
    [Semicolon, ..rest] -> {
      // We're cutting corners here and only returning the first eval...
      use #(_eval_s, tokens) <- result.map(run(S, rest, None))
      #(eval_a, tokens)
    }
    _ -> Error(Nil)
  }
}

// S -> ε
fn three(
  tokens: List(Token),
  eval_option: Option(EvaluationResult),
) -> Result(#(Option(EvaluationResult), List(Token)), Nil) {
  epsilon(tokens, eval_option)
}

// A -> x= A
fn four(
  tokens: List(Token),
) -> Result(#(Option(EvaluationResult), List(Token)), Nil) {
  case tokens {
    [AssignmentT(to_variable), ..rest] -> {
      use #(eval_option, tokens) <- result.try(run(A, rest, None))
      case eval_option {
        Some(eval) -> Ok(#(Some(Assignment(eval.value, to_variable)), tokens))
        None -> Error(Nil)
      }
    }
    _ -> Error(Nil)
  }
}

// A -> E
fn five(
  tokens: List(Token),
) -> Result(#(Option(EvaluationResult), List(Token)), Nil) {
  run(E, tokens, None)
}

// E -> TE'
fn six(
  tokens: List(Token),
) -> Result(#(Option(EvaluationResult), List(Token)), Nil) {
  use #(eval_option, tokens) <- result.try(run(T, tokens, None))
  case eval_option {
    Some(eval) -> {
      use #(eval, tokens) <- result.map(run(Ep, tokens, Some(eval)))
      #(eval, tokens)
    }
    None -> Error(Nil)
  }
}

// E' -> ε
fn nine(
  tokens: List(Token),
  eval_option: Option(EvaluationResult),
) -> Result(#(Option(EvaluationResult), List(Token)), Nil) {
  epsilon(tokens, eval_option)
}

// T -> PT'
fn ten(
  tokens: List(Token),
) -> Result(#(Option(EvaluationResult), List(Token)), Nil) {
  use #(eval_option, tokens) <- result.try(run(P, tokens, None))
  run(Tp, tokens, eval_option)
}

// T' -> ε
fn thirteen(
  tokens: List(Token),
  eval_option: Option(EvaluationResult),
) -> Result(#(Option(EvaluationResult), List(Token)), Nil) {
  epsilon(tokens, eval_option)
}

// P -> FP'
fn fourteen(
  tokens: List(Token),
) -> Result(#(Option(EvaluationResult), List(Token)), Nil) {
  use #(eval_option, tokens) <- result.try(run(F, tokens, None))
  run(Pp, tokens, eval_option)
}

// P' -> ε
fn sixteen(
  tokens: List(Token),
  eval_option: Option(EvaluationResult),
) -> Result(#(Option(EvaluationResult), List(Token)), Nil) {
  epsilon(tokens, eval_option)
}

// F -> a (value literal)
fn eighteen(
  tokens: List(Token),
) -> Result(#(Option(EvaluationResult), List(Token)), Nil) {
  case tokens {
    [Value(value), ..rest] -> Ok(#(Some(Expression(value)), rest))
    _ -> Error(Nil)
  }
}

fn epsilon(
  tokens: List(Token),
  eval_option: Option(EvaluationResult),
) -> Result(#(Option(EvaluationResult), List(Token)), Nil) {
  Ok(#(eval_option, tokens))
}

module Fractional = {
  type t = {q: float, r: float, s: float}

  let make: (float, float) => t = (q, r) => {q, r, s: q *. -1.0 -. r *. -1.0}

  let toString = hex => {
    let {q, r, s} = hex
    `Hex(${q->Float.toString}, ${r->Float.toString}, ${s->Float.toString})`
  }
}

type t = {q: int, r: int, s: int}

let make: (int, int, int) => t = (q, r, s) =>
  if q + r + s == 0 {
    {q, r, s: -q - r}
  } else {
    panic("Invalid hex coordinates")
  }

let make2: (int, int) => t = (q, r) => make(q, r, -q - r)

let directions = [
  // Clockwise from top-left
  make(0, -1, 1), // Top-left
  make(1, -1, 0), // Top-right
  make(1, 0, -1), // Right
  make(0, 1, -1), // Bottom-right
  make(-1, 1, 0), // Bottom-left
  make(-1, 0, 1), // Left
]

let hexAreEqual = (a: t, b: t) => a.q == b.q && a.r == b.r && a.s == b.s

let hexAdd: (t, t) => t = (a, b) => {q: a.q + b.q, r: a.r + b.r, s: a.s + b.s}

let toString: t => string = hex => {
  let {q, r, s} = hex
  `Hex(${q->Int.toString}, ${r->Int.toString}, ${s->Int.toString})`
}

let hexDirection = direction => {
  if direction > 0 && direction < 6 {
    directions[direction]
  } else {
    panic("Invalid direction")
  }
}

let hexNeighbor = (hex, direction) =>
  switch hexDirection(direction) {
  | Some(hexDirection) => hexAdd(hex, hexDirection)
  | None => hex
  }

let hexNeighbors = hex => directions->Array.map(direction => hexAdd(hex, direction))

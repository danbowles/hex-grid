type t = {q: int, r: int, s: int}
type tFloat = {q: float, r: float, s: float}

let make: (int, int, int) => t = (q, r, s) =>
  if q + r + s == 0 {
    {q, r, s: -q - r}
  } else {
    panic("Invalid hex coordinates")
  }

let make2: (int, int) => t = (q, r) => make(q, r, -q - r)

let directions = [
  make(1, 0, -1),
  make(1, -1, 0),
  make(0, -1, 1),
  make(-1, 0, 1),
  make(-1, 1, 0),
  make(0, 1, -1),
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

let toFloat: t => tFloat = (hex: t) => {
  q: Float.parseInt(hex.q),
  r: Float.parseInt(hex.r),
  s: Float.parseInt(hex.s),
}

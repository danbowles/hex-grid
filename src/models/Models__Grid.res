module HashTable = Models__HexHashTable
module Hexagon = Models__Hexagon

external infinity: int = "Infinity"

type minMax = {min: int, max: int}
type bounds = {qMin: int, qMax: int, rMin: int, rMax: int}

type t = {grid: HashTable.t, bounds: bounds}

let makeRectangle = (~height, ~width) => {
  let (left, right) = (-width / 2, width / 2)
  let (top, bottom) = (-height / 2, height / 2)
  let grid = HashTable.make()
  for r in top to bottom {
    let rOffset = Math.floor(r->Float.parseInt /. 2.0)
    let q1 = (left->Float.parseInt -. rOffset)->Int.fromFloat
    let q2 = (right->Float.parseInt -. rOffset)->Int.fromFloat
    for q in q1 to q2 {
      let s = -q - r
      let hex = Hexagon.make(q, r, s)
      grid->HashTable.insert(hex)
    }
  }

  let bounds =
    grid
    ->Dict.valuesToArray
    ->Array.reduce({qMin: infinity, qMax: -infinity, rMin: infinity, rMax: -infinity}, (
      {qMin, qMax, rMin, rMax},
      {q, r, _},
    ) => {
      qMin: Math.min(qMin->float, q->float)->Float.toInt,
      qMax: Math.max(qMax->float, q->float)->Float.toInt,
      rMin: Math.min(rMin->float, r->float)->Float.toInt,
      rMax: Math.max(rMax->float, r->float)->Float.toInt,
    })

  {grid, bounds}
}
let mapGrid = ({grid}: t, mapFn) => {
  grid
  ->Dict.valuesToArray
  ->Array.map(mapFn)
}

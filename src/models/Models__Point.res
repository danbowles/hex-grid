type t = {x: int, y: int}
type tFloat = {x: float, y: float}

let make: (int, int) => t = (x, y) => {x, y}

let toFloat: t => tFloat = point => {x: Float.parseInt(point.x), y: Float.parseInt(point.y)}

let toInt: tFloat => t = (point: tFloat) => {
  let {x, y} = point
  {x: Int.fromFloat(x), y: Int.fromFloat(y)}
}

let toString: tFloat => string = p => {
  `${p.x->Float.toString},${p.y->Float.toString}`
}

let makeFloat: (float, float) => tFloat = (x, y) => {x, y}

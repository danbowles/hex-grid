type t = {x: float, y: float}

let make: (float, float) => t = (x, y) => {x, y}

let toString: t => string = p => {
  `${p.x->Float.toString},${p.y->Float.toString}`
}

let x = (point: t) => point.x
let y = (point: t) => point.y

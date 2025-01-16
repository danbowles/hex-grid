open Models__Orientation
module Point = Models__Point
module Hexagon = Models__Hexagon
module Orientation = Models__Orientation

type t = {
  orientation: Orientation.t,
  size: Point.t,
  origin: Point.tFloat,
}

let make = (orientation, size, origin) => {orientation, size, origin}

let hexToPixel: (t, Hexagon.t) => Point.tFloat = (layout, hex: Hexagon.t) => {
  let {f0, f1, f2, f3} = layout.orientation
  let {x: sX, y: sY} = Point.toFloat(layout.size)
  let {x: originX, y: originY} = layout.origin
  let {q, r} = Hexagon.toFloat(hex)

  let x = (f0 *. q +. f1 *. r) *. sX +. Float.parseInt(originX)
  let y = (f2 *. q +. f3 *. r) *. sY +. Float.parseInt(originY)
  {x, y}
}
// TODO: Fractional Hex + Rounding
// let pixelToHex: (t, Point.tFloat) => Hex.t = (layout, point) => {
//   let {b0, b1, b2, b3} = layout.orientation
//   let {x: sizeX, y: sizeY} = Point.toFloat(layout.size)
//   let {x: originX, y: originY} = Point.toFloat(layout.origin)
//   let {x: px, y: py} = Point.make((point.x -. originX) /. sizeX, (point.y -. originY) /. sizeY)
//   let {x, y} = point

//   let q = (b0 *. px +. b1 *. py -. Float.parseInt(originX)) /. x
//   let r = (b2 *. px +. b3 *. py -. Float.parseInt(originY)) /. y
//   Hex.make(q, r, -q -. r)
// }

let hexCornerOffset: (t, int) => Point.tFloat = (layout, corner) => {
  let {x: sX, y: sY} = Point.toFloat(layout.size)
  let startAngle = layout.orientation.startAngle
  let angle = 2.0 *. Math.Constants.pi *. (startAngle +. Float.parseInt(corner)) /. 6.0

  Point.makeFloat(sX *. Math.cos(angle), sY *. Math.sin(angle))
}

let polygonCorners: (t, Hexagon.t) => array<Point.tFloat> = (layout, hex) => {
  let corners = []
  let center = hexToPixel(layout, hex)

  for i in 0 to 5 {
    let offset = hexCornerOffset(layout, i)
    let {x, y} = center
    let {x: ox, y: oy} = offset
    let point = Point.makeFloat(x +. ox, y +. oy)
    corners->Array.push(point)
  }

  corners
}

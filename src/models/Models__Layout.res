open Models__Orientation
module Point = Models__Point
module Hexagon = Models__Hexagon
module Orientation = Models__Orientation

type t = {
  orientation: Orientation.t,
  size: Point.t,
  origin: Point.t,
}

let int = Float.toInt

let make = (orientation, size, origin) => {orientation, size, origin}

let hexToPixel: (t, Hexagon.t) => Point.t = (layout, hex: Hexagon.t) => {
  let {f0, f1, f2, f3} = layout.orientation
  let {x: sX, y: sY} = layout.size
  let {x: originX, y: originY} = layout.origin
  let qFloat = Float.parseInt(hex.q)
  let rFloat = Float.parseInt(hex.r)

  let x = (f0 *. qFloat +. f1 *. rFloat) *. sX +. originX
  let y = (f2 *. qFloat +. f3 *. rFloat) *. sY +. originY
  {x, y}
}
let pixelToHex: (t, Point.t) => Hexagon.Fractional.t = (layout, point) => {
  // const Orientation& M = layout.orientation;
  // Point pt = Point((p.x - layout.origin.x) / layout.size.x,
  //                  (p.y - layout.origin.y) / layout.size.y);
  // double q = M.b0 * pt.x + M.b1 * pt.y;
  // double r = M.b2 * pt.x + M.b3 * pt.y;
  // return FractionalHex(q, r, -q - r);

  // const q = (x * Math.sqrt(3) / 3 - y / 3) / size;
  // const r = y * 2 / 3 / size;
  // return { q, r };

  let {b0, b1, b2, b3} = layout.orientation
  let {x: sizeX, y: sizeY} = layout.size
  let {x: originX, y: originY} = layout.origin
  let {x: px, y: py} = Point.make((point.x -. originX) /. sizeX, (point.y -. originY) /. sizeY)

  let q = b0 *. px +. b1 *. py
  let r = b2 *. px +. b3 *. py
  Hexagon.Fractional.make(q, r)
}

let hexRound: Hexagon.Fractional.t => Hexagon.t = fractionalHexagon => {
  let q = Math.round(fractionalHexagon.q)
  let r = Math.round(fractionalHexagon.r)
  let negQ = -1.0 *. q
  let negR = -1.0 *. r
  let s = Math.round(negQ -. r)

  let qDiff = Math.abs(q -. fractionalHexagon.q)
  let rDiff = Math.abs(r -. fractionalHexagon.r)
  let sDiff = Math.abs(s -. fractionalHexagon.s)

  let (q: float, r: float, s: float) = switch (qDiff > rDiff && qDiff > sDiff, rDiff > sDiff) {
  | (true, _) => (negR -. s, r, s)
  | (_, true) => (q, negQ -. s, s)
  | _ => (q, r, negQ -. r)
  }

  Hexagon.make(q->int, r->int, s->int)
}

let hexCornerOffset: (t, int) => Point.t = (layout, corner) => {
  let {x: sX, y: sY} = layout.size
  let startAngle = layout.orientation.startAngle
  let angle = 2.0 *. Math.Constants.pi *. (startAngle +. Float.parseInt(corner)) /. 6.0

  Point.make(sX *. Math.cos(angle), sY *. Math.sin(angle))
}

let polygonCorners: (t, Hexagon.t) => array<Point.t> = (layout, hex) => {
  let corners = []
  let center = hexToPixel(layout, hex)

  for i in 0 to 5 {
    let offset = hexCornerOffset(layout, i)
    let {x, y} = center
    let {x: ox, y: oy} = offset
    let point = Point.make(x +. ox, y +. oy)
    corners->Array.push(point)
  }

  corners
}

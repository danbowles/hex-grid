module Point = {
  type t = {x: int, y: int}
  type tFloat = {x: float, y: float}

  let make: (int, int) => t = (x, y) => {x, y}

  let toFloat: t => tFloat = point => {x: Float.parseInt(point.x), y: Float.parseInt(point.y)}

  let toInt: tFloat => t = (point: tFloat) => {
    let {x, y} = point
    {x: Int.fromFloat(x), y: Int.fromFloat(y)}
  }

  let makeFloat: (float, float) => tFloat = (x, y) => {x, y}
}

module Hex = {
  type t = {q: int, r: int, s: int}
  type tFloat = {q: float, r: float, s: float}

  let make: (int, int, int) => t = (q, r, s) =>
    if q + r + s == 0 {
      {q, r, s: -q - r}
    } else {
      panic("Invalid hex coordinates")
    }

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
}

module Orientation = {
  type t = {
    // Forward matrix Hex -> Pixel
    f0: float,
    f1: float,
    f2: float,
    f3: float,
    // Backward matrix Pixel -> Hex
    b0: float,
    b1: float,
    b2: float,
    b3: float,
    // Angle modifier for 'pointy' or 'flat' orientation
    startAngle: float,
  }

  let make = (f0, f1, f2, f3, b0, b1, b2, b3, startAngle) => {
    f0,
    f1,
    f2,
    f3,
    b0,
    b1,
    b2,
    b3,
    startAngle,
  }

  let pointy = make(
    // F0, F1, F2, F3
    Math.sqrt(3.0),
    Math.sqrt(3.0) /. 2.0,
    0.0,
    3.0 /. 2.0,
    // B0, B1, B2, B3
    Math.sqrt(3.0) /. 3.0,
    -1.0 /. 3.0,
    0.0,
    2.0 /. 3.0,
    // startAngle
    0.5,
  )
}

module Layout = {
  type t = {
    orientation: Orientation.t,
    size: Point.t,
    origin: Point.tFloat,
  }

  let make = (orientation, size, origin) => {orientation, size, origin}

  let hexToPixel: (t, Hex.t) => Point.tFloat = (layout, hex: Hex.t) => {
    let {f0, f1, f2, f3} = layout.orientation
    let {x: sX, y: sY} = Point.toFloat(layout.size)
    let {x: originX, y: originY} = layout.origin
    let {q, r} = Hex.toFloat(hex)

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

  let polygonCorners: (t, Hex.t) => array<Point.tFloat> = (layout, hex) => {
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
}

module HexHashTable = {
  type t = Dict.t<Hex.t>

  let make = () => Dict.make()

  let hash: Hex.t => string = hex => {
    let {q, r} = hex
    let key = `${q->Int.toString},${r->Int.toString}`
    key
  }

  let insert = (map, hex) => Dict.set(map, hex->hash, hex)
  let get = (map, hex) => Dict.get(map, hex->hash)
  let remove = (map, hex) => Dict.delete(map, hex->hash)
}

module HexagonalMap = {
  type t = {
    hashTable: HexHashTable.t,
    size: int,
  }

  let min = (a, b) =>
    if a < b {
      a
    } else {
      b
    }
  let max = (a, b) =>
    if a > b {
      a
    } else {
      b
    }

  let make = size => {
    let hashTable = HexHashTable.make()
    for q in -size to size {
      let r1 = max(-size, -q - size)
      let r2 = min(size, -q + size)
      for r in r1 to r2 {
        let s = -q - r
        let hex = Hex.make(q, r, s)
        hashTable->HexHashTable.insert(hex)
      }
    }

    {hashTable, size}
  }

  let toArray = (map: t) => map.hashTable->Dict.valuesToArray
}
module ParallelogramMap = {
  type direction = LeftRight | TopBottom | RightLeft
  type t = {
    hashTable: HexHashTable.t,
    direction: direction,
  }

  let makeLeftRight = (q1, q2, r1, r2) => {
    let hashTable = HexHashTable.make()
    for q in q1 to q2 {
      for r in r1 to r2 {
        let s = -q - r
        let hex = Hex.make(q, r, s)
        hashTable->HexHashTable.insert(hex)
      }
    }

    {hashTable, direction: LeftRight}
  }
  let make: (int, direction) => t = (size, direction) => {
    switch direction {
    | _ => makeLeftRight(-size, size, -size, size)
    }
  }

  let toArray = (map: t) => map.hashTable->Dict.valuesToArray
}

module RectangularMap = {
  type t = {hashTable: HexHashTable.t}

  let make = (~left, ~right, ~top, ~bottom) => {
    let hashTable = HexHashTable.make()
    for r in top to bottom {
      let rOffset = Math.floor(r->Float.parseInt /. 2.0)
      let q1 = (left->Float.parseInt -. rOffset)->Int.fromFloat
      let q2 = (right->Float.parseInt -. rOffset)->Int.fromFloat
      for q in q1 to q2 {
        let s = -q - r
        let hex = Hex.make(q, r, s)
        hashTable->HexHashTable.insert(hex)
      }
    }

    {hashTable: hashTable}
  }

  let toArray = (map: t) => map.hashTable->Dict.valuesToArray
}

module TriangularMap = {
  type t = {hashTable: HexHashTable.t}

  let make = size => {
    let hashTable = HexHashTable.make()
    for q in 0 to size {
      for r in 0 to size - q {
        let s = -q - r
        let hex = Hex.make(q, r, s)
        hashTable->HexHashTable.insert(hex)
      }
    }

    {hashTable: hashTable}
  }

  let toArray = (map: t) => map.hashTable->Dict.valuesToArray
}

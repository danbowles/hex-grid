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

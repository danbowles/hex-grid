let seededRandom = (x: float, y: float) => {
  let n = Math.sin(x * 127.1 +. y * 311.7) * 43758.5453
  n - Math.floor(n)
}

open Models__Point

let rec noisyPoints = (a: t, b: t, ~amplitude: float, ~minLength: float): array<t> => {
  let dx = b.x - a.x
  let dy = b.y - a.y
  let length = Math.sqrt(dx * dx +. dy * dy)
  if length < minLength {
    [a, b]
  } else {
    let mx = (a.x + b.x) / 2.0
    let my = (a.y + b.y) / 2.0
    let r = seededRandom(mx, my) * 2.0 - 1.0 // remap to [-1, 1]
    let m = make(mx + -.dy / length * r * amplitude, my + dx / length * r * amplitude)
    let left = noisyPoints(a, m, ~amplitude=amplitude / 2.0, ~minLength)
    let right = noisyPoints(m, b, ~amplitude=amplitude / 2.0, ~minLength)
    left->Array.slice(~start=0, ~end=left->Array.length - 1)->Array.concat(right)
  }
}

let rec noisyPointsSalted = (a: t, b: t, ~amplitude: float, ~minLength: float, ~salt: float): array<
  t,
> => {
  let dx = b.x - a.x
  let dy = b.y - a.y
  let length = Math.sqrt(dx * dx +. dy * dy)
  if length < minLength {
    [a, b]
  } else {
    let mx = (a.x + b.x) / 2.0
    let my = (a.y + b.y) / 2.0
    let r = seededRandom(mx + salt, my + salt) * 2.0 - 1.0 // remap to [-1, 1]
    let m = make(mx + -.dy / length * r * amplitude, my + dx / length * r * amplitude)
    let left = noisyPointsSalted(a, m, ~amplitude=amplitude / 2.0, ~minLength, ~salt)
    let right = noisyPointsSalted(m, b, ~amplitude=amplitude / 2.0, ~minLength, ~salt)
    left->Array.slice(~start=0, ~end=left->Array.length - 1)->Array.concat(right)
  }
}

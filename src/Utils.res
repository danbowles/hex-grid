open Models

let getRandomInt = (min, max) => {
  let min = Math.ceil(min->float)
  let max = Math.floor(max->float)
  Math.floor(Math.random() *. (max -. min +. 1.0) +. min)->Float.toInt
}

let getRandomHexagon = ({grid, bounds}: Grid.t) => {
  let {qMin, qMax, rMin, rMax} = bounds
  let rec loop = () => {
    let q = getRandomInt(qMin, qMax)
    let r = getRandomInt(rMin, rMax)
    let hex = Hexagon.make2(q, r)
    if grid->Grid.inBounds(hex) {
      hex
    } else {
      loop()
    }
  }
  loop()
}

let makeWalls = (grid: Grid.t, count) => {
  let walls = HashTable.make()
  for _ in 0 to count {
    let hex = grid->getRandomHexagon
    walls->HashTable.insert(hex)
  }
  walls
}

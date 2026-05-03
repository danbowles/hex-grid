open Models

let getRandomInt = (min, max) => {
  let min = Math.ceil(min->Int.toFloat)
  let max = Math.floor(max->Int.toFloat)
  Math.floor(Math.random() *. (max -. min +. 1.0) +. min)->Float.toInt
}

let getRandomHexagon = (grid: Grid.t, ~walls=?) => {
  let walls = switch walls {
  | Some(walls) => walls
  | None => HashTable.make()
  }
  let {qMin, qMax, rMin, rMax} = grid.bounds
  let rec loop = () => {
    let q = getRandomInt(qMin, qMax)
    let r = getRandomInt(rMin, rMax)
    let hex = Hexagon.make2(q, r)
    if grid->Grid.inBounds(hex) && !Grid.isWall(walls, hex) {
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
    walls->HashTable.insert(hex)->ignore
  }
  walls
}

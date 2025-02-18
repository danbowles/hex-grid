module Grid = Models__Grid
module HashTable = Models__HexHashTable
module Hexagon = Models__Hexagon

type t = {grid: HashTable.WithData.t, bounds: Grid.bounds}

let validColors =
  ["green", "blue", "purple", "yellow", "red", "orange"]->Array.map(color => `fill-${color}-300`)

let getRandomColor = () => {
  let randomIndex = mod((Math.random() *. 1000.0)->Int.fromFloat, validColors->Array.length)
  validColors->Array.get(randomIndex)->Option.getExn
}

let make = (grid: Grid.t) => {
  let {bounds} = grid
  let dataHashTable = HashTable.WithData.make()

  grid.grid
  ->Dict.valuesToArray
  ->Array.forEach(hex => {
    let neighborColors =
      hex
      ->Hexagon.hexNeighbors
      ->Belt.Array.keepMap(neighbor =>
        switch dataHashTable->HashTable.WithData.get(neighbor) {
        | None => None
        | Some({color}) => Some(color)
        }
      )

    let color = if neighborColors->Array.length > 0 && Math.random() < 0.5123 {
      neighborColors
      ->Array.get(mod((Math.random() *. 1000.0)->Int.fromFloat, neighborColors->Array.length))
      ->Option.getExn
    } else {
      getRandomColor()
    }

    dataHashTable->HashTable.WithData.insert({hex, color})->ignore
  })

  {grid: dataHashTable, bounds}
}

let mapGrid = (grid: t, mapFn) => {
  grid.grid
  ->Dict.valuesToArray
  ->Array.map(mapFn)
}

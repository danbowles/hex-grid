module HexHashTable = Models__HexHashTable
module Hexagon = Models__Hexagon

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
        let hex = Hexagon.make(q, r, s)
        hashTable->HexHashTable.insert(hex)->ignore
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
        let hex = Hexagon.make(q, r, s)
        hashTable->HexHashTable.insert(hex)->ignore
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
        let hex = Hexagon.make(q, r, s)
        hashTable->HexHashTable.insert(hex)->ignore
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
        let hex = Hexagon.make(q, r, s)
        hashTable->HexHashTable.insert(hex)->ignore
      }
    }

    {hashTable: hashTable}
  }

  let toArray = (map: t) => map.hashTable->Dict.valuesToArray
}

module TerrainMap = {
  module HexWithTerrain = {
    type t = {hex: Hexagon.t, terrain: Models__Terrain.t}
  }
  module TerrainMapHashTable = {
    type t = Dict.t<HexWithTerrain.t>

    let make = () => Dict.make()
    let hash: Hexagon.t => string = hex => {
      let {q, r} = hex
      let key = `${q->Int.toString},${r->Int.toString}`
      key
    }

    let insert = (map: t, hex: Hexagon.t, terrain: Models__Terrain.t) =>
      Dict.set(map, hex->hash, {hex, terrain})
    let get = (map, hex) => Dict.get(map, hex->hash)
    let remove = (map, hex) => Dict.delete(map, hex->hash)
    let updateTerrain = (map, hex, terrainKind) => {
      switch map->get(hex) {
      | Some(_) => {
          insert(map, hex, Models__Terrain.make(terrainKind))
          map
        }
      | None => map
      }
    }
    let fillMapWithTerrain = (map, terrainKind) => {
      map->Dict.forEach(hexWithTerrain => {
        insert(map, hexWithTerrain.hex, Models__Terrain.make(terrainKind))
      })
      map
    }
  }

  type t = {
    hashTable: TerrainMapHashTable.t,
    // size: int,
  }

  let make = (~height: int, ~width: int) => {
    let hashTable = TerrainMapHashTable.make()
    let (left, right) = (-width / 2, width / 2)
    let (top, bottom) = (-height / 2, height / 2)
    for r in top to bottom {
      let rOffset = Math.floor(r->Float.parseInt /. 2.0)
      let q1 = (left->Float.parseInt -. rOffset)->Int.fromFloat
      let q2 = (right->Float.parseInt -. rOffset)->Int.fromFloat
      for q in q1 to q2 {
        let s = -q - r
        let hex = Hexagon.make(q, r, s)
        let terrain = switch (q, r, s) {
        | (q, r, s)
          if q == -width / 2 ||
          q == width / 2 ||
          r == -height / 2 ||
          r == height / 2 ||
          s == -width / 2 ||
          s == width / 2 =>
          Models__Terrain.make(Water)
        | (0, 0, _) => Models__Terrain.make(Grass)
        | (0, 1, _) => Models__Terrain.make(Water)
        | (1, 0, _) => Models__Terrain.make(Sand)
        | (1, 1, _) => Models__Terrain.make(Mountain)
        | _ => Models__Terrain.make(Grass)
        }
        hashTable->TerrainMapHashTable.insert(hex, terrain)
      }
    }

    {hashTable: hashTable}
  }
}

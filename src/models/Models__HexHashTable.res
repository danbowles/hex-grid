open Models__Hexagon

type t = Dict.t<Models__Hexagon.t>

let make = () => Dict.make()

let hash: Models__Hexagon.t => string = hex => {
  let {q, r} = hex
  let key = `${q->Int.toString},${r->Int.toString}`
  key
}

let insert = (map, hex) => {
  Dict.set(map, hex->hash, hex)
  map
}
let get = (map, hex) => Dict.get(map, hex->hash)
let remove = (map, hex) => {
  Dict.delete(map, hex->hash)
  map
}

module WithData = {
  type hexWithData = {
    hex: Models__Hexagon.t,
    color: string,
  }
  type t = Dict.t<hexWithData>

  let make = make
  let get = (dict: t, hex: Models__Hexagon.t) => Dict.get(dict, hex->hash)

  let insert = (dict: t, hexData) => {
    Dict.set(dict, hexData.hex->hash, hexData)
    dict
  }
}

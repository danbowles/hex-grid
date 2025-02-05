module Grid = Models__Grid
module Hexagon = Models__Hexagon
module Queue = Models__Queue

let hash = Models__HexHashTable.hash

type t<'a> = {
  visited: Dict.t<bool>,
  cameFrom: Dict.t<Hexagon.t>,
  queue: Queue.t<Hexagon.t>,
}

let breadthFirstSearch = (~start, ~goal, ~grid: Grid.t, ~walls) => {
  let state = {
    visited: Dict.make(),
    cameFrom: Dict.make(),
    queue: Queue.put(Queue.makeEmpty(), start),
  }

  state.visited->Dict.set(start->hash, true)

  let rec search = state =>
    switch Queue.get(state.queue) {
    | None => None
    | Some((queue, currentHex)) =>
      let neighbors =
        Hexagon.hexNeighbors(currentHex)
        ->Array.filter(Grid.inBounds(grid, _))
        ->Array.filter(hex => !Grid.isWall(walls, hex))
      if currentHex == goal {
        // Reconstruct path
        let rec reconstructPath: (Hexagon.t, list<Hexagon.t>) => list<Hexagon.t> = (hex, path) =>
          switch Dict.get(state.cameFrom, hex->hash) {
          | None => list{hex, ...path}
          | Some(prev) => reconstructPath(prev, list{hex, ...path})
          }

        Some(reconstructPath(currentHex, list{}))
      } else {
        // Explore neighbors
        let updatedState = Js.List.foldLeft((state: t<'a>, neighbor: Hexagon.t) => {
          switch Dict.get(state.visited, neighbor->hash) {
          | None
          | Some(false) => {
              Js.Dict.set(state.visited, neighbor->hash, true)
              Js.Dict.set(state.cameFrom, neighbor->hash, currentHex)
              {
                ...state,
                queue: Queue.put(state.queue, neighbor),
              }
            }
          | _ => state
          }
        }, {...state, queue}, List.fromArray(neighbors))
        search(updatedState)
      }
    }

  search(state)
}

open Models
module MapControlState = {
  let name = "MapControlState"
  type state = {
    showColors: bool,
    showDebugCircle: bool,
    showCoords: bool,
    highlightNeighbors: bool,
  }

  type action = ShowColors | ShowDebugCircle | ShowCoords | HighlightNeighbors

  let reducer = (state, action) => {
    switch action {
    | ShowColors => {...state, showColors: !state.showColors}
    | ShowDebugCircle => {...state, showDebugCircle: !state.showDebugCircle}
    | ShowCoords => {...state, showCoords: !state.showCoords}
    | HighlightNeighbors => {...state, highlightNeighbors: !state.highlightNeighbors}
    }
  }

  let empty = () => {
    showColors: true,
    showDebugCircle: false,
    showCoords: true,
    highlightNeighbors: true,
  }
}

let useToggleReducer = () => {
  let (state, dispatch) = React.useReducer(MapControlState.reducer, MapControlState.empty())
  (state, dispatch)
}

module PathfindingGridState = {
  let name = "PathfindingGridState"
  type state = {
    grid: Grid.t,
    walls: Dict.t<Hexagon.t>,
    startingHex: Hexagon.t,
    endingHex: Hexagon.t,
    draggingStartHex: Hexagon.t,
    draggingEndHex: Hexagon.t,
    path: option<list<Hexagon.t>>,
  }

  type action =
    | SetStartingHex(Hexagon.t)
    | SetEndingHex(Hexagon.t)
    | SetDraggingStartHex(Hexagon.t)
    | SetDraggingEndHex(Hexagon.t)
    | CreateWall(Hexagon.t)
    | RemoveWall(Hexagon.t)

  let updatePath: state => state = state => {
    let path = GridBfs.breadthFirstSearch(
      ~start=state.draggingStartHex,
      ~goal=state.draggingEndHex,
      ~grid=state.grid,
      ~walls=state.walls,
    )
    {...state, path}
  }

  let isValidHexagon = (hexagon, state) =>
    Grid.inBounds(state.grid, hexagon) && !Grid.isWall(state.walls, hexagon)

  let reducer = (state, action) => {
    switch action {
    | SetDraggingStartHex(hex) =>
      if Hexagon.hexAreEqual(hex, state.endingHex) || !isValidHexagon(hex, state) {
        state
      } else {
        updatePath({...state, draggingStartHex: hex})
      }
    | SetDraggingEndHex(hex) =>
      if Hexagon.hexAreEqual(hex, state.startingHex) || !isValidHexagon(hex, state) {
        state
      } else {
        updatePath({...state, draggingEndHex: hex})
      }
    | SetStartingHex(hex) => {...state, startingHex: hex}
    | SetEndingHex(hex) => {...state, endingHex: hex}
    | CreateWall(hex) => updatePath({...state, walls: HashTable.insert(state.walls, hex)})
    | RemoveWall(hex) => updatePath({...state, walls: HashTable.remove(state.walls, hex)})
    }
  }
}

let usePathfindingGridState = (~height, ~width, ~wallCount) => {
  let grid = Grid.makeRectangle(~height, ~width)
  let walls = Utils.makeWalls(grid, wallCount)
  let startingHex = Utils.getRandomHexagon(grid, ~walls)
  let endingHex = Utils.getRandomHexagon(grid, ~walls)

  // DEBUG
  // let startingHex = Hexagon.make(0, 0, 0)
  // let endingHex = Hexagon.make2(1, 0)

  // let walls = HashTable.make()
  // walls->HashTable.insert(Hexagon.make2(2, 0))->ignore
  // END DEBUG
  let (state, dispatch) = React.useReducer(
    PathfindingGridState.reducer,
    {
      grid,
      walls,
      startingHex,
      endingHex,
      draggingStartHex: startingHex,
      draggingEndHex: endingHex,
      path: GridBfs.breadthFirstSearch(~start=startingHex, ~goal=endingHex, ~grid, ~walls),
    },
  )
  (state, dispatch)
}

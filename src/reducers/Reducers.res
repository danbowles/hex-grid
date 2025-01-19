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

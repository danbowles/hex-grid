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
    highlightNeighbors: false,
  }
}

let useToggleReducer = () => {
  let (state, dispatch) = React.useReducer(MapControlState.reducer, MapControlState.empty())
  (state, dispatch)
}

module Figure = {
  @react.component
  let make = (~caption=?, ~children) => {
    <figure>
      {switch caption {
      | Some(caption) =>
        <figcaption className="text-2xl font-mono font-bold mb-3 text-gray-500">
          {caption->React.string}
        </figcaption>
      | None => <> </>
      }}
      <div className="border-4 border-indigo-200 rounded-lg mb-6"> {children} </div>
    </figure>
  }
}

module ControlsContext = {
  let context = React.createContext(MapControlState.empty())

  let useContext = () => React.useContext(context)

  module Provider = {
    let provider = React.Context.provider(context)
    @react.component
    let make = (~value, ~children) => {
      React.createElement(provider, {value, children})
    }
  }
}

module FigureWithControls = {
  @react.component
  let make = (~caption=?, ~children) => {
    let (state, dispatch) = useToggleReducer()
    <figure className="flex flex-col shadow-lg border border-blue-700 rounded overflow-hidden">
      {switch caption {
      | Some(caption) =>
        <figcaption className="bg-blue-700 text-white text-xl font-mono font-bold mb-3 p-4">
          {caption->React.string}
        </figcaption>
      | None => <> </>
      }}
      <div className="p-2">
        <div className="flex justify-center space-x-4 mb-4">
          <label className="flex items-center space-x-2">
            <input
              type_="checkbox"
              className="form-checkbox h-5 w-5 text-blue-600"
              checked={state.showColors}
              onChange={_ => dispatch(ShowColors)}
            />
            <span className="text-gray-700"> {"Show Colors"->React.string} </span>
          </label>
          <label className="flex items-center space-x-2">
            <input
              type_="checkbox"
              className="form-checkbox h-5 w-5 text-blue-600"
              checked={state.showDebugCircle}
              onChange={_ => dispatch(ShowDebugCircle)}
            />
            <span className="text-gray-700"> {"Show Debug Circle"->React.string} </span>
          </label>
          <label className="flex items-center space-x-2">
            <input
              type_="checkbox"
              className="form-checkbox h-5 w-5 text-blue-600"
              checked={state.showCoords}
              onChange={_ => dispatch(ShowCoords)}
            />
            <span className="text-gray-700"> {"Show Coords"->React.string} </span>
          </label>
        </div>
        <div className="">
          <ControlsContext.Provider value={state}> {children} </ControlsContext.Provider>
        </div>
      </div>
    </figure>
  }
}

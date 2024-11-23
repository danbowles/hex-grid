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

module LayoutContext = {
  let size = Point.makeFloat(10.0, 10.0)
  let origin = Point.makeFloat(size.x, size.y *. Math.sqrt(3.0) /. 2.0)
  let layout = Layout.make(Orientation.pointy, size->Point.toInt, origin)
  let context = React.createContext(layout)

  let useContext = () => React.useContext(context)

  module Provider = {
    let provider = React.Context.provider(context)
    @react.component
    let make = (~value, ~children) => {
      React.createElement(provider, {value, children})
    }
  }
}

module MapMakerFigure = {
  @react.component
  let make = (~caption=?, ~children) => {
    let buttonStyles = [
      ("Water", "bg-blue-500 text-white"),
      ("Sand", "bg-yellow-500 text-black"),
      ("Mountains", "bg-gray-700 text-white"),
      ("Grass", "bg-green-500 text-white"),
    ]
    // let (canDraw, _) = CanDrawContext.useContext()
    <figure>
      {switch caption {
      | Some(caption) =>
        <figcaption className="text-xl font-mono font-bold p-4">
          {caption->React.string}
        </figcaption>
      | None => <> </>
      }}
      <LayoutContext.Provider value={LayoutContext.layout}>
        <div className="flex space-x-2">
          {buttonStyles
          ->Array.map(((label, className)) =>
            <button className={className ++ " p-2 rounded"}> {label->React.string} </button>
          )
          ->React.array}
          <span className="text-gray-800 text-sm">
            // {canDraw ? "Drawing"->React.string : "Not Drawing"->React.string}
          </span>
        </div>
        {children}
      </LayoutContext.Provider>
    </figure>
  }
}

module FigureWithControls = {
  @react.component
  let make = (~caption=?, ~children) => {
    let (state, dispatch) = useToggleReducer()
    let controls: array<(MapControlState.action, bool, string)> = [
      (ShowColors, state.showColors, "Colors"),
      (ShowDebugCircle, state.showDebugCircle, "Debug"),
      (ShowCoords, state.showCoords, "Coords"),
      (HighlightNeighbors, state.highlightNeighbors, "Neighbors"),
    ]
    <figure className="flex flex-col shadow-lg border border-blue-700 rounded overflow-hidden">
      {switch caption {
      | Some(caption) =>
        <figcaption className="bg-blue-700 text-white text-xl font-mono font-bold p-4">
          {caption->React.string}
        </figcaption>
      | None => <> </>
      }}
      <div className="p-2">
        <div className="flex justify-center space-x-4 mb-3">
          {controls
          ->Array.map(((action, checked, label)) =>
            <label className="flex items-center space-x-2">
              <input
                type_="checkbox"
                className="form-checkbox h-4 w-4 text-blue-600"
                checked
                onChange={_ => dispatch(action)}
                key={label}
              />
              <span className="text-gray-800 text-sm"> {label->React.string} </span>
            </label>
          )
          ->React.array}
        </div>
        <div className="">
          <LayoutContext.Provider value={LayoutContext.layout}>
            <ControlsContext.Provider value={state}> {children} </ControlsContext.Provider>
          </LayoutContext.Provider>
        </div>
      </div>
    </figure>
  }
}

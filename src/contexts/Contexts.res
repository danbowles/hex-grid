open Reducers
open Models

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

module DraggingContext = {
  let context = React.createContext(false)

  let useContext = () => React.useContext(context)

  module Provider = {
    let provider = React.Context.provider(context)
    @react.component
    let make = (~value, ~children) => {
      React.createElement(provider, {value, children})
    }
  }
}

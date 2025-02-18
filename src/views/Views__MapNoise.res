open Contexts
open Models
open Svg

module NoisyGrid = {
  @react.component
  let make = (~grid) => {
    let layout = LayoutContext.useContext()

    grid
    ->DataGrid.mapGrid(({hex, color}) => {
      let key = hex->Models.Hexagon.toString
      let points =
        layout
        ->Layout.polygonCorners(hex)
        ->Array.map(Point.toString)
        ->Array.join(",")
      <polygon key className={"stroke-slate-900 " ++ color} points />
      // <polygon key className={"stroke-slate-900 " ++ color} points />
    })
    ->React.array
  }
}

@react.component
let make = () => {
  let grid = Grid.makeRectangle(~height=14, ~width=18)->DataGrid.make
  <figure>
    <LayoutContext.Provider value={LayoutContext.layout}>
      <Svg>
        <NoisyGrid grid />
      </Svg>
    </LayoutContext.Provider>
  </figure>
}

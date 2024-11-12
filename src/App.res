open Figure
open Footer
open Header
open HexText
open FigureWithControls
open Models
open Svg

module Hexagon = {
  @react.component
  let make = (
    ~layout: Layout.t,
    ~hex: Hex.t,
    ~showColors,
    ~showCoords,
    ~showDebugCircle,
    ~onMouseEnter,
    ~onMouseLeave,
    ~isActive=false,
    ~isNeighborOfActive=false,
    ~isNeighborOfNeighborOfActive=false,
  ) => {
    let style = ReactDOM.Style.make(~strokeWidth="0.3", ())
    let {q, r, s} = hex
    let hexCorners = layout->Layout.polygonCorners(hex)
    let pointsString = Js.Array.map(
      (p: Point.tFloat) => `${p.x->Float.toString},${p.y->Float.toString}`,
      hexCorners,
    )
    let {x, y} = layout->Layout.hexToPixel(hex)

    let hexFill = switch (q, r, s) {
    | (0, r, s) if r != 0 && s != 0 => "fill-rose-100"
    | (q, 0, s) if q != 0 && s != 0 => "fill-green-100"
    | (q, r, 0) if q != 0 && r != 0 => "fill-blue-100"
    | _ => "fill-slate-50"
    }
    let classNames = "stroke-slate-500"
    let hexFill = switch (showColors, isActive, isNeighborOfActive, isNeighborOfNeighborOfActive) {
    | (_, true, _, _) => "fill-amber-300"
    | (_, _, true, _) => "fill-amber-200"
    | (_, _, _, true) => "fill-amber-100"
    | (true, false, false, false) => hexFill
    | (false, _, _, _) => "fill-slate-50"
    }
    let classNames = `${classNames} ${hexFill}`

    <>
      <polygon
        className={classNames}
        points={Js.Array.joinWith(",", pointsString)}
        style={style}
        onMouseEnter
        onMouseLeave
      />
      <g>
        {showDebugCircle
          ? <circle cx={x->Float.toString} cy={y->Float.toString} r="1" className="fill-red-500" />
          : <> </>}
        {showCoords ? <HexText q r s x y /> : <> </>}
      </g>
    </>
  }
}

let useNestedNeighbors = (activeHex: option<Hex.t>) => {
  let (hexNeighbors, neighborNeighbors) = switch activeHex {
  | None => ([], [])
  | Some(hex) => {
      let neighbors = hex->Hex.hexNeighbors
      let neighborNeighbors = neighbors->Array.flatMap(neighbor => neighbor->Hex.hexNeighbors)
      let neighborsAndActive = neighbors->Array.concat([hex])
      let neighborNeighbors = neighborNeighbors->Array.filter(nn => {
        switch neighborsAndActive->Array.find(n => Hex.hexAreEqual(n, nn)) {
        | Some(_) => false
        | _ => true
        }
      })
      (neighbors, neighborNeighbors)
    }
  }
  (hexNeighbors, neighborNeighbors)
}

let renderHex = (
  ~hex,
  ~activeHex,
  ~neighbors,
  ~neighborNeighbors,
  ~layout,
  ~controlState: MapControlState.state,
  ~setActiveHex,
) => {
  let {showColors, showCoords, showDebugCircle} = controlState
  let key = hex->Hex.toString
  let isActive = switch activeHex {
  | Some(activeHex) => Hex.hexAreEqual(hex, activeHex)
  | None => false
  }
  let isNeighborOfActive = neighbors->Array.some(neighbor => Hex.hexAreEqual(neighbor, hex))
  let isNeighborOfNeighborOfActive =
    neighborNeighbors->Array.some(neighbor => Hex.hexAreEqual(neighbor, hex))
  let onMouseEnter = controlState.highlightNeighbors ? _ => setActiveHex(_ => Some(hex)) : _ => ()
  let onMouseLeave = controlState.highlightNeighbors ? _ => setActiveHex(_ => None) : _ => ()
  <Hexagon
    key
    layout
    hex
    showColors
    showCoords
    showDebugCircle
    onMouseEnter
    onMouseLeave
    isActive
    isNeighborOfActive
    isNeighborOfNeighborOfActive
  />
}

module HexagonGrid = {
  @react.component
  let make = (~size) => {
    let controlState = ControlsContext.useContext()
    let layout = LayoutContext.useContext()
    let (activeHex: option<Hex.t>, setActiveHex) = React.useState(_ => None)
    let (neighbors, neighborNeighbors) = useNestedNeighbors(activeHex)

    HexagonalMap.make(size)
    ->HexagonalMap.toArray
    ->Array.map(hex => {
      renderHex(
        ~hex,
        ~activeHex,
        ~neighbors,
        ~neighborNeighbors,
        ~layout,
        ~controlState,
        ~setActiveHex,
      )
    })
    ->React.array
  }
}

module ParallelogramGrid = {
  @react.component
  let make = (~size, ~direction: ParallelogramMap.direction) => {
    let controlState = ControlsContext.useContext()
    let layout = LayoutContext.useContext()
    let (activeHex: option<Hex.t>, setActiveHex) = React.useState(_ => None)
    let (neighbors, neighborNeighbors) = useNestedNeighbors(activeHex)

    ParallelogramMap.make(size, direction)
    ->ParallelogramMap.toArray
    ->Array.map(hex => {
      renderHex(
        ~hex,
        ~activeHex,
        ~neighbors,
        ~neighborNeighbors,
        ~layout,
        ~controlState,
        ~setActiveHex,
      )
    })
    ->React.array
  }
}

module RectangularGrid = {
  @react.component
  let make = (~left, ~right, ~top, ~bottom) => {
    let controlState = ControlsContext.useContext()
    let layout = LayoutContext.useContext()
    let (activeHex: option<Hex.t>, setActiveHex) = React.useState(_ => None)
    let (neighbors, neighborNeighbors) = useNestedNeighbors(activeHex)

    RectangularMap.make(~left, ~right, ~top, ~bottom)
    ->RectangularMap.toArray
    ->Array.map(hex => {
      renderHex(
        ~hex,
        ~activeHex,
        ~neighbors,
        ~neighborNeighbors,
        ~layout,
        ~controlState,
        ~setActiveHex,
      )
    })
    ->React.array
  }
}

module TriangularGrid = {
  @react.component
  let make = (~size) => {
    let controlState = ControlsContext.useContext()
    let layout = LayoutContext.useContext()
    let (activeHex: option<Hex.t>, setActiveHex) = React.useState(_ => None)
    let (neighbors, neighborNeighbors) = useNestedNeighbors(activeHex)

    TriangularMap.make(size)
    ->TriangularMap.toArray
    ->Array.map(hex => {
      renderHex(
        ~hex,
        ~activeHex,
        ~neighbors,
        ~neighborNeighbors,
        ~layout,
        ~controlState,
        ~setActiveHex,
      )
    })
    ->React.array
  }
}

@react.component
let make = () => {
  <>
    <div className="flex flex-col min-h-screen w-full max-w-screen-xl mx-auto">
      <Header />
      <div className="px-4 mt-3">
        <p className="md:hidden">
          <HeroIcons.Solid.DevicePhoneMobileIcon className="h-6 w-6 mr-2 inline-block" />
          {"Tap for 'Neighbors' Highlight"->React.string}
        </p>
        <p className="hidden md:block">
          <HeroIcons.Solid.ComputerDesktopIcon className="h-6 w-6 mr-2 inline-block" />
          {"Hover for 'Neighbors' Highlight"->React.string}
        </p>
      </div>
      <main className="flex-grow p-4">
        <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
          <FigureWithControls caption="Parallelogram Map">
            <Svg>
              <ParallelogramGrid size={4} direction={ParallelogramMap.LeftRight} />
            </Svg>
          </FigureWithControls>
          <FigureWithControls caption="Hexagon Map">
            <Svg>
              <HexagonGrid size={6} />
            </Svg>
          </FigureWithControls>
          <FigureWithControls caption="Rectangular Map">
            <Svg>
              <RectangularGrid left={-5} right={5} top={-4} bottom={4} />
            </Svg>
          </FigureWithControls>
          <FigureWithControls caption="Triangular Map">
            <Svg>
              <TriangularGrid size={8} />
            </Svg>
          </FigureWithControls>
        </div>
      </main>
      <Footer />
    </div>
  </>
}

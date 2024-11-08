open Figure
open Header
open HexText
open FigureWithControls
open Models
open Svg

module Hexagon = {
  @react.component
  let make = (~layout: Layout.t, ~hex: Hex.t, ~showColors, ~showCoords, ~showDebugCircle, ~onMouseEnter, ~onMouseLeave, ~active=false) => {
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
    let hexFill = switch (showColors, active) {
    | (_, true) => "fill-amber-300"
    | (true, false) => hexFill
    | (false, _) => "fill-slate-50"
    }
    let classNames = `${classNames} ${hexFill}`

    <>
      <polygon className={classNames} points={Js.Array.joinWith(",", pointsString)} style={style} onMouseEnter onMouseLeave/>
      <g>
        {showDebugCircle
          ? <circle cx={x->Float.toString} cy={y->Float.toString} r="1" className="fill-red-500" />
          : <> </>}
        {showCoords ? <HexText q r s x y /> : <> </>}
      </g>
    </>
  }
}

module HexagonGrid = {
  @react.component
  let make = (~size) => {
    let {showColors, showCoords, showDebugCircle} = ControlsContext.useContext()
    let hexMap = HexagonalMap.make(size)
    let size = Point.makeFloat(10.0, 10.0)
    let origin = Point.makeFloat(size.x, size.y *. Math.sqrt(3.0) /. 2.0)
    let layout = Layout.make(Orientation.pointy, size->Point.toInt, origin)

    let hexes = HexagonalMap.toArray(hexMap)
    hexes
    ->Array.map(hex => {
      let key = hex->Hex.toString
      <Hexagon key layout hex showColors showCoords showDebugCircle onMouseEnter={_ => ()} onMouseLeave={_=>()}/>
    })
    ->React.array
  }
}

module ParallelogramGrid = {
  @react.component
  let make = (~size, ~direction: ParallelogramMap.direction) => {
    let {showColors, showCoords, showDebugCircle} = ControlsContext.useContext()
    let parallelogramMap = ParallelogramMap.make(size, direction)
    let size = Point.makeFloat(10.0, 10.0)
    let origin = Point.makeFloat(size.x, size.y *. Math.sqrt(3.0) /. 2.0)
    let layout = Layout.make(Orientation.pointy, size->Point.toInt, origin)

    let hexes = ParallelogramMap.toArray(parallelogramMap)
    hexes
    ->Array.map(hex => {
      let key = hex->Hex.toString
      <Hexagon key layout hex showColors showCoords showDebugCircle onMouseEnter={_ => ()} onMouseLeave={_=>()}/>
    })
    ->React.array
  }
}

module RectangularGrid = {
  @react.component
  let make = (~left, ~right, ~top, ~bottom) => {
    let (activeHex: option<Hex.t>, setActiveHex) = React.useState(_ => None)
    let (neighbors: array<Hex.t>, setNeighbors) = React.useState(_ => [])

    React.useEffect1(() => {
      let hexNeighbors = switch activeHex {
      | None => []
      | Some(hex) => hex->Hex.hexNeighbors
      }
      setNeighbors(_ => hexNeighbors)
      None
    }, [activeHex])
    let {showColors, showCoords, showDebugCircle} = ControlsContext.useContext()
    let rectangularMap = RectangularMap.make(~left, ~right, ~top, ~bottom)
    let size = Point.makeFloat(10.0, 10.0)
    let origin = Point.makeFloat(size.x, size.y *. Math.sqrt(3.0) /. 2.0)
    let layout = Layout.make(Orientation.pointy, size->Point.toInt, origin)

    let hexes = RectangularMap.toArray(rectangularMap)
    hexes
    ->Array.map(hex => {
      let key = hex->Hex.toString
      let isActive = switch activeHex {
        | Some(activeHex) => Hex.hexAreEqual(hex, activeHex)
        | None => false
      }
      <Hexagon
        key
        layout
        hex
        showColors
        showCoords
        showDebugCircle
        onMouseEnter={_ => setActiveHex(_ => Some(hex))}
        onMouseLeave={_ => setActiveHex(_ => None)}
        active={isActive}
      />
    })
    ->React.array
  }
}

@react.component
let make = () => {
  <div className="w-full max-w-screen-xl mx-auto mt-8 mb-8 pl-5 pr-5">
    <Header />
    <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
      <FigureWithControls caption="Parallelogram Map">
        <Svg>
          <ParallelogramGrid size={6} direction={ParallelogramMap.LeftRight} />
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
    </div>
  </div>
}

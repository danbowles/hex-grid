open Contexts
open Svg
open Models

module Utils = {
  let getRandomInt = (min, max) => {
    let min = Math.ceil(min->float)
    let max = Math.floor(max->float)
    Math.floor(Math.random() *. (max -. min +. 1.0) +. min)->Float.toInt
  }
}

module GridUtils = {
  let getRandomHexagon = ({grid, bounds}: Grid.t) => {
    let {qMin, qMax, rMin, rMax} = bounds
    let rec loop = () => {
      let q = Utils.getRandomInt(qMin, qMax)
      let r = Utils.getRandomInt(rMin, rMax)
      switch grid->Grid.HashTable.get(Hexagon.make2(q, r)) {
      | None => loop()
      | Some(hex) => hex
      }
    }
    loop()
  }
}

let useSvgDrag = (~x, ~y) => {
  let (coords: Point.tFloat, setCoordinates) = React.useState(_ => Point.makeFloat(x, y))
  let (dragging, setDragging) = React.useState(_ => false)

  let startDrag = _ => {
    setDragging(_ => true)
  }

  let drag = (x, y) => {
    if dragging {
      setCoordinates(_ => Point.makeFloat(x, y))
    }
  }

  let stopDrag = _ => {
    setDragging(_ => false)
  }

  (coords, dragging, startDrag, drag, stopDrag)
}

module PatfindingGrid = {
  module DraggableStart = {
    @react.component
    let make = (~x, ~y) => {
      let dragging = DraggingContext.useContext()
      let (matrixInversed, _) = ScreenCtmContext.useContext()
      let (circleCoords, setCircleCoords) = React.useState(_ => Point.makeFloat(x, y))
      let (_, _, startDrag, _, stopDrag) = useSvgDrag(~x, ~y)
      let style = ReactDOM.Style.make(
        ~fontSize="3px",
        ~fontFamily="monospace",
        ~pointerEvents="none",
        (),
      )

      let onMouseDown = _ => {
        startDrag()
      }

      let onMouseMove = (event: JsxEvent.Mouse.t) => {
        if dragging {
          let cX = event->PervasivesU.JsxEvent.Mouse.clientX->float
          let cY = event->PervasivesU.JsxEvent.Mouse.clientY->float
          let domP = createDomPoint(cX, cY)
          let {x: sX, y: sY} = matrixTransform(domP, matrixInversed)
          setCircleCoords(_ => Point.makeFloat(sX, sY))
        }
      }

      let onMouseUp = _ => {
        stopDrag()
      }
      let onMouseLeave = _ => {
        // stopDrag()
        ()
      }
      <g onMouseDown onMouseMove onMouseUp onMouseLeave>
        <circle
          cx={circleCoords.x->Float.toString}
          cy={circleCoords.y->Float.toString}
          r="4"
          className="fill-green-400"
        />
        // <text
        //   style
        //   textAnchor="middle"
        //   x={circleCoords.x->Float.toString}
        //   y={circleCoords.y->Float.toString}>
        //   {`(${circleCoords.x->Float.toFixed}, ${circleCoords.y->Float.toString})`->React.string}
        // </text>
      </g>
    }
  }
  @react.component
  let make = (~grid) => {
    let layout = LayoutContext.useContext()
    Js.log("Rendering Pathfinding Grid")

    grid
    ->Grid.mapGrid(hexagon => {
      let key = hexagon->Models.Hexagon.toString
      let points =
        layout
        ->Layout.polygonCorners(hexagon)
        ->Array.map(Point.toString)
        ->Array.join(",")
      <polygon key className={`stroke-slate-900 fill-slate-50 `} points />
    })
    ->React.array
  }
}

@react.component
let make = () => {
  let grid = Grid.makeRectangle(~height=14, ~width=20)
  let layout = LayoutContext.useContext()
  let startingHex = GridUtils.getRandomHexagon(grid)
  let endingHex = GridUtils.getRandomHexagon(grid)
  let {x, y} = layout->Layout.hexToPixel(startingHex)
  let {x: endX, y: endY} = layout->Layout.hexToPixel(endingHex)

  <figure>
    <LayoutContext.Provider value={LayoutContext.layout}>
      <Svg>
        <PatfindingGrid grid />
        <PatfindingGrid.DraggableStart x y />
        <PatfindingGrid.DraggableStart x={endX} y={endY} />
      </Svg>
    </LayoutContext.Provider>
  </figure>
}

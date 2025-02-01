open Contexts
open Models
open Svg

let useSvgDrag = (~x, ~y) => {
  let (coords: Point.t, setCoordinates) = React.useState(_ => Point.make(x, y))
  let (dragging, setDragging) = React.useState(_ => false)

  let startDrag = _ => {
    setDragging(_ => true)
  }

  let drag = (x, y) => {
    if dragging {
      setCoordinates(_ => Point.make(x, y))
    }
  }

  let stopDrag = _ => {
    setDragging(_ => false)
  }

  (coords, dragging, startDrag, drag, stopDrag)
}

module PatfindingGrid = {
  module Draggable = {
    type draggable = Start | End

    @react.component
    let make = (~point, ~grid: Grid.t, ~walls, ~setHexagon, ~type_) => {
      let {grid} = grid
      let dragging = DraggingContext.useContext()
      let layout = LayoutContext.useContext()
      let (matrixInversed, _) = ScreenCtmContext.useContext()
      let (circleCoords, setCircleCoords) = React.useState(_ => point)
      let (r, setR) = React.useState(_ => "4")

      let onMouseDown = _ => {
        setR(_ => "7")
        ()
      }

      let onMouseMove = (event: JsxEvent.Mouse.t) => {
        if dragging {
          let cX = event->PervasivesU.JsxEvent.Mouse.clientX->float
          let cY = event->PervasivesU.JsxEvent.Mouse.clientY->float
          let domP = createDomPoint(cX, cY)
          let {x: sX, y: sY} = matrixTransform(domP, matrixInversed)
          setCircleCoords(_ => Point.make(sX, sY))

          let fractionalHexagon = Layout.pixelToHex(
            layout,
            Point.make(circleCoords.x, circleCoords.y),
          )
          let roundedHex = Layout.hexRound(fractionalHexagon)
          let setNewHex = switch (Grid.inBounds(grid, roundedHex), Grid.isWall(walls, roundedHex)) {
          | (true, false) => true
          | _ => false
          }
          if setNewHex {
            setHexagon(roundedHex)
          }
        }
      }

      let onMouseUp = _ => {
        let fractionalHexagon = Layout.pixelToHex(
          layout,
          Point.make(circleCoords.x, circleCoords.y),
        )
        let roundedHex = Layout.hexRound(fractionalHexagon)
        let (snappedPixel, setNewHex) = switch (
          Grid.inBounds(grid, roundedHex),
          Grid.isWall(walls, roundedHex),
        ) {
        | (true, false) => (Layout.hexToPixel(layout, roundedHex), true)
        | _ => (point, false)
        }
        setCircleCoords(_ => snappedPixel)
        if setNewHex {
          setHexagon(roundedHex)
        }
        setR(_ => "4")
      }
      let onMouseLeave = _ => {
        Js.log("Mouse left")
        ()
      }

      let className = switch type_ {
      | Start => "fill-green-400"
      | End => "fill-rose-400"
      }
      <g onMouseDown onMouseMove onMouseUp onMouseLeave>
        <circle
          cx={circleCoords.x->Float.toString} cy={circleCoords.y->Float.toString} r className
        />
      </g>
    }
  }

  @react.component
  let make = (~grid) => {
    let layout = LayoutContext.useContext()

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
let make = (~grid, ~walls) => {
  let layout = LayoutContext.useContext()
  let (startingHex, setStartingHex) = React.useState(_ => Utils.getRandomHexagon(grid))
  let (endingHex, setEndingHex) = React.useState(_ => Utils.getRandomHexagon(grid))

  let path = GridBfs.breadthFirstSearch(~start=startingHex, ~goal=endingHex, ~grid, ~walls)

  let linePoints = path->Option.map(path => {
    path
    ->List.toArray
    ->Array.map(hexagon => {
      let {x, y} = layout->Layout.hexToPixel(hexagon)
      Point.make(x, y)
    })
    ->Array.map(Point.toString)
    ->Array.join(" ")
  })

  let renderWall = hexagon => {
    let {x, y} = layout->Layout.hexToPixel(hexagon)
    let cx = x->Float.toString
    let cy = y->Float.toString
    let key = hexagon->Models.Hexagon.toString
    <circle key cx cy r="7.5" className="fill-slate-300" />
  }

  <figure>
    <LayoutContext.Provider value={LayoutContext.layout}>
      <Svg>
        <PatfindingGrid grid />
        {switch path {
        | None => <> </>
        | Some(path) =>
          let pathArr = path->List.toArray
          pathArr
          ->Array.map(hexagon => {
            let key = hexagon->Models.Hexagon.toString
            let points =
              layout
              ->Layout.polygonCorners(hexagon)
              ->Array.map(Point.toString)
              ->Array.join(",")
            <polygon key className={`stroke-slate-900 fill-blue-100`} points />
          })
          ->React.array
        }}
        <polyline points={linePoints->Option.getOr("")} className="stroke-blue-400" fill="none" />
        // "Walls"
        {walls->Dict.valuesToArray->Array.map(renderWall)->React.array}
        <PatfindingGrid.Draggable
          point={layout->Layout.hexToPixel(startingHex)}
          grid
          walls
          setHexagon={hex => {
            setStartingHex(_ => hex)
          }}
          type_={PatfindingGrid.Draggable.Start}
        />
        // <circle
        //   cx={endX->Float.toString} cy={endY->Float.toString} r="4" className="fill-rose-400"
        // />
        <PatfindingGrid.Draggable
          point={layout->Layout.hexToPixel(endingHex)}
          grid
          walls
          setHexagon={hex => {
            setEndingHex(_ => hex)
          }}
          type_={PatfindingGrid.Draggable.End}
        />
      </Svg>
    </LayoutContext.Provider>
  </figure>
}

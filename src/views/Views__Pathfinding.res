open Contexts
open Models
open Svg
open Reducers

@get external pointerId: JsxEvent.Pointer.t => float = "pointerId"

module PatfindingGrid = {
  module Draggable = {
    type draggable = Start | End
    type position = {point: Point.t, active: bool, translate: Point.t}

    @react.component
    let make = (~point: Point.t, ~type_, ~onPointerMove, ~onPointerUp) => {
      let layout = LayoutContext.useContext()
      let (matrixInversed, _) = ScreenCtmContext.useContext()
      let (r, setR) = React.useState(_ => "4")
      let (position, setPosition) = React.useState(_ => {
        point,
        active: false,
        translate: Point.make(0.0, 0.0),
      })

      let handlePointerDown = event => {
        setR(_ => "7")
        event->PervasivesU.JsxEvent.Pointer.target->setPointerCaptureForObj(event->pointerId)
        setPosition(_ => {
          ...position,
          active: true,
        })
      }

      let handlePointerMove = event => {
        let cX = event->PervasivesU.JsxEvent.Pointer.clientX->float
        let cY = event->PervasivesU.JsxEvent.Pointer.clientY->float
        if position.active {
          let domP = createDomPoint(cX, cY)
          let {x: sX, y: sY} = matrixTransform(domP, matrixInversed)
          setPosition(_ => {
            ...position,
            point: Point.make(sX, sY),
            translate: Point.make(sX -. point.x, sY -. point.y),
          })
          onPointerMove(Layout.pixelToHex(layout, Point.make(sX, sY))->Layout.hexRound)
        }
      }

      let handlePointerUp = _ => {
        setPosition(_ => {
          ...position,
          active: false,
          translate: Point.make(0.0, 0.0),
        })
        setR(_ => "4")
        onPointerUp()
      }

      let className = switch type_ {
      | Start => "fill-green-400"
      | End => "fill-rose-400"
      }

      let className =
        className ++
        switch position.active {
        | true => " cursor-grabbing"
        | false => " cursor-grab"
        }

      <circle
        onPointerDown={handlePointerDown}
        onPointerMove={handlePointerMove}
        onPointerUp={handlePointerUp}
        transform={`translate(${position.translate->Point.toString})`}
        cx={point.x->Float.toString}
        cy={point.y->Float.toString}
        r
        className
      />
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
let make = () => {
  let (state, dispatch) = usePathfindingGridState(~height=14, ~width=20, ~wallCount=100)
  let layout = LayoutContext.useContext()
  let {walls, grid} = state

  let points =
    state.path->Option.map(path => path->List.map(hexagon => layout->Layout.hexToPixel(hexagon)))

  let computeMidpoints: List.t<Point.t> => List.t<Point.t> = points => {
    let pa = points->List.toArray
    let paRes = []
    let forFinish = pa->Array.length - 2

    for i in 0 to forFinish {
      let p1 = pa->Array.get(i)->Option.getExn
      let p2 = pa->Array.get(i + 1)->Option.getExn
      let midX = (p1.x +. p2.x) /. 2.0
      let midY = (p1.y +. p2.y) /. 2.0
      paRes->Array.push(Point.make(midX, midY))
    }
    List.fromArray(paRes)
  }

  let smoothPolylineToBezier = (points: List.t<Point.t>) => {
    let midpoints = computeMidpoints(points)->List.toArray
    let pa = points->List.toArray
    let firstPoint = pa->Array.get(0)->Option.getExn
    let path = [`M${firstPoint.x->Float.toString},${firstPoint.y->Float.toString}`] // Start at first point
    let forEnd = midpoints->Array.length - 2

    for i in 0 to forEnd {
      let control = pa->Array.get(i + 1)->Option.getExn // Original point as control
      let nextMid = midpoints->Array.get(i + 1)->Option.getExn // Next midpoint as curve anchor

      path->Array.push(
        ` Q${control.x->Float.toString},${control.y->Float.toString} ${nextMid.x->Float.toString},${nextMid.y->Float.toString}`,
      )
    }

    // Ensure the curve ends at the last point
    let lastPoint = pa->Array.get(pa->Array.length - 1)->Option.getExn
    path->Array.push(` T${lastPoint.x->Float.toString},${lastPoint.y->Float.toString}`)
    path->Array.join("")
  }

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
        // "Walls"
        {walls->Dict.valuesToArray->Array.map(renderWall)->React.array}
        <path
          d={smoothPolylineToBezier(points->Option.getOr(list{}))}
          className="stroke-blue-400 fill-none"
          strokeWidth="5"
          strokeLinejoin="round"
          strokeLinecap="round"
        />
        <PatfindingGrid.Draggable
          point={layout->Layout.hexToPixel(state.startingHex)}
          onPointerMove={hex => dispatch(PathfindingGridState.SetDraggingStartHex(hex))}
          onPointerUp={_ => dispatch(PathfindingGridState.SetStartingHex(state.draggingStartHex))}
          type_={PatfindingGrid.Draggable.Start}
        />
        <PatfindingGrid.Draggable
          point={layout->Layout.hexToPixel(state.endingHex)}
          onPointerMove={hex => dispatch(PathfindingGridState.SetDraggingEndHex(hex))}
          onPointerUp={_ => dispatch(PathfindingGridState.SetEndingHex(state.draggingEndHex))}
          type_={PatfindingGrid.Draggable.End}
        />
      </Svg>
    </LayoutContext.Provider>
  </figure>
}

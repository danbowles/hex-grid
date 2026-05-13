open Webapi.Canvas
open Models
open Reducers

@scope("window") @val external devicePixelRatio: float = "devicePixelRatio"

type coastlineLoop = array<Point.t>
type nativeMouseEvent
@get external nativeEvent: ReactEvent.Mouse.t => nativeMouseEvent = "nativeEvent"
@get external offsetX: nativeMouseEvent => int = "offsetX"
@get external offsetY: nativeMouseEvent => int = "offsetY"

let clear = (ctx, ~width, ~height) => {
  ctx->Canvas2d.setFillStyle(String, "white")
  ctx->Canvas2d.fillRect(~x=0.0, ~y=0.0, ~w=width, ~h=height)
}

let drawHex = (ctx, layout, hex) => {
  let corners = Layout.polygonCorners(layout, hex)
  ctx->Canvas2d.beginPath
  corners->Array.forEachWithIndex((point, i) =>
    if i == 0 {
      ctx->Canvas2d.moveTo(~x=point.x, ~y=point.y)
    } else {
      ctx->Canvas2d.lineTo(~x=point.x, ~y=point.y)
    }
  )
  ctx->Canvas2d.closePath
  ctx->Canvas2d.setFillStyle(String, "#93c5fd")
  ctx->Canvas2d.setStrokeStyle(String, "#2F5363")
  ctx->Canvas2d.fill
  ctx->Canvas2d.stroke
}

let drawHexFill = (ctx, layout, hex) => {
  let corners = Layout.polygonCorners(layout, hex)
  ctx->Canvas2d.beginPath
  corners->Array.forEachWithIndex((point, i) =>
    if i == 0 {
      ctx->Canvas2d.moveTo(~x=point.x, ~y=point.y)
    } else {
      ctx->Canvas2d.lineTo(~x=point.x, ~y=point.y)
    }
  )
  ctx->Canvas2d.closePath
  ctx->Canvas2d.setFillStyle(String, "#93c5fd")
  ctx->Canvas2d.fill
}

let drawNoisyEdgeFill = (ctx, layout, state: HashTable.t, hex) => {
  let corners = Layout.polygonCorners(layout, hex)
  let neighbors = Hexagon.hexNeighbors(hex)
  let firstCorner = corners->Array.getUnsafe(0)
  ctx->Canvas2d.beginPath
  ctx->Canvas2d.moveTo(~x=firstCorner.x, ~y=firstCorner.y)
  for i in 0 to 5 {
    let a = corners->Array.getUnsafe(i)
    let b = corners->Array.getUnsafe(mod(i + 1, 6))
    let neighbor = neighbors->Array.getUnsafe(mod(i + 3, 6))
    switch HashTable.get(state, neighbor) {
    | Some(_) => ctx->Canvas2d.lineTo(~x=b.x, ~y=b.y)
    | None =>
      let points = Noise.noisyPoints(a, b, ~amplitude=8.0, ~minLength=4.0)
      points
      ->Array.sliceToEnd(~start=1)
      ->Array.forEach(pt => ctx->Canvas2d.lineTo(~x=pt.x, ~y=pt.y))
    }
  }
  ctx->Canvas2d.closePath
  ctx->Canvas2d.setFillStyle(String, "#8FA36B")
  ctx->Canvas2d.fill
}

let drawBoundaryEdges = (ctx, layout, state: HashTable.t, hex) => {
  let corners = Layout.polygonCorners(layout, hex)
  let neighbors = Hexagon.hexNeighbors(hex)
  ctx->Canvas2d.setStrokeStyle(String, "#C8B889")
  ctx->Canvas2d.lineWidth(5.0)
  for i in 0 to 5 {
    let getIndex = mod(i + 3, 6)
    let neighbor = neighbors->Array.getUnsafe(getIndex)
    switch HashTable.get(state, neighbor) {
    | Some(_) => ()
    | None =>
      let a = corners->Array.getUnsafe(i)
      let b = corners->Array.getUnsafe(mod(i + 1, 6))
      let points = Noise.noisyPoints(a, b, ~amplitude=8.0, ~minLength=4.0)
      ctx->Canvas2d.beginPath
      points->Array.forEachWithIndex((pt, j) =>
        if j == 0 {
          ctx->Canvas2d.moveTo(~x=pt.x, ~y=pt.y)
        } else {
          ctx->Canvas2d.lineTo(~x=pt.x, ~y=pt.y)
        }
      )
      ctx->Canvas2d.stroke
    }
  }
}

type boundaryEdge = {
  a: Point.t,
  b: Point.t,
}

type waterBand = {
  color: string,
  width: float,
  amplitude: float,
  minLength: float,
  salt: float,
}

let pointKey = (point: Point.t) => {
  let x = Math.round(point.x *. 1000.0)
  let y = Math.round(point.y *. 1000.0)
  `${x->Float.toString}:${y->Float.toString}`
}

let pointsMatch = (a: Point.t, b: Point.t) => pointKey(a) == pointKey(b)

let collectBoundaryEdges = (layout, state: HashTable.t): array<boundaryEdge> => {
  let edges = []
  state
  ->Dict.valuesToArray
  ->Array.forEach(hex => {
    let corners = Layout.polygonCorners(layout, hex)
    let neighbors = Hexagon.hexNeighbors(hex)

    for i in 0 to 5 {
      let neighbor = neighbors->Array.getUnsafe(mod(i + 3, 6))
      switch HashTable.get(state, neighbor) {
      | Some(_) => ()
      | None =>
        let a = corners->Array.getUnsafe(i)
        let b = corners->Array.getUnsafe(mod(i + 1, 6))
        edges->Array.push({a, b})
      }
    }
  })
  edges
}

let findNextBoundaryEdge = (
  boundaryEdges: array<boundaryEdge>,
  visited: array<bool>,
  currentPoint: Point.t,
) => {
  let index =
    boundaryEdges->Array.findIndexWithIndex((edge, index) =>
      !(visited->Array.getUnsafe(index)) &&
      (pointsMatch(edge.a, currentPoint) || pointsMatch(edge.b, currentPoint))
    )

  switch index {
  | -1 => None
  | index =>
    let edge = boundaryEdges->Array.getUnsafe(index)
    let nextPoint = pointsMatch(edge.a, currentPoint) ? edge.b : edge.a
    Some((index, nextPoint))
  }
}

let collectCoastlineLoops = (boundaryEdges: array<boundaryEdge>): array<coastlineLoop> => {
  let loops: array<coastlineLoop> = []
  let visited = Array.make(~length=boundaryEdges->Array.length, false)

  boundaryEdges->Array.forEachWithIndex((edge, index) => {
    if !(visited->Array.getUnsafe(index)) {
      visited->Array.setUnsafe(index, true)

      let coastline = [edge.a, edge.b]
      let startKey = pointKey(edge.a)

      let rec walk = currentPoint => {
        if pointKey(currentPoint) == startKey {
          ()
        } else {
          switch findNextBoundaryEdge(boundaryEdges, visited, currentPoint) {
          | Some((nextIndex, nextPoint)) =>
            visited->Array.setUnsafe(nextIndex, true)
            coastline->Array.push(nextPoint)
            walk(nextPoint)
          | None => ()
          }
        }
      }

      walk(edge.b)

      if coastline->Array.length > 2 {
        loops->Array.push(coastline)
      }
    }
  })

  loops
}

let drawCoastBand = (ctx, coastlineLoops, ~color, ~width, ~amplitude, ~minLength, ~salt) => {
  ctx->Canvas2d.save
  ctx->Canvas2d.setStrokeStyle(String, color)
  ctx->Canvas2d.lineWidth(width)
  ctx->Canvas2d.lineCap(Canvas2d.LineCap.round)
  ctx->Canvas2d.lineJoin(Canvas2d.LineJoin.round)

  coastlineLoops->Array.forEach(coastline => {
    ctx->Canvas2d.beginPath
    coastline->Array.forEachWithIndex((point: Point.t, index) => {
      if index == 0 {
        ctx->Canvas2d.moveTo(~x=point.x, ~y=point.y)
      } else {
        let previousPoint = coastline->Array.getUnsafe(index - 1)
        let points = Noise.noisyPointsSalted(previousPoint, point, ~amplitude, ~minLength, ~salt)
        points
        ->Array.sliceToEnd(~start=1)
        ->Array.forEach((point: Point.t) => ctx->Canvas2d.lineTo(~x=point.x, ~y=point.y))
      }
    })

    switch coastline->Array.get(coastline->Array.length - 1) {
    | Some(lastPoint) =>
      if pointsMatch(lastPoint, coastline->Array.getUnsafe(0)) {
        ctx->Canvas2d.closePath
      }
    | None => ()
    }

    ctx->Canvas2d.stroke
  })

  ctx->Canvas2d.restore
}

let drawWaterBands = (ctx, coastlineLoops) => {
  let waterBands = [
    {color: "#4F7483", width: 64.0, amplitude: 8.0, minLength: 10.0, salt: 11.0},
    {color: "#7797A0", width: 48.0, amplitude: 4.0, minLength: 8.0, salt: 23.0},
    {color: "#9FB7B7", width: 32.0, amplitude: 3.0, minLength: 6.0, salt: 37.0},
    // {color: "#C8B889", width: 5.0, amplitude: 8.0, minLength: 5.0, salt: 41.0},
  ]
  waterBands->Array.forEach((band: waterBand) => {
    drawCoastBand(
      ctx,
      coastlineLoops,
      ~color=band.color,
      ~width=band.width,
      ~amplitude=band.amplitude,
      ~minLength=band.minLength,
      ~salt=band.salt,
    )
  })
}

let maybeRenderWater = (ctx, layout, state, width, height, showWater) => {
  //for the entire size of the grid, fill the canvas with a deep blue
  if showWater {
    ctx->Canvas2d.setFillStyle(String, "#2F5363")
    ctx->Canvas2d.fillRect(~x=0.0, ~y=0.0, ~w=width, ~h=height)

    let boundaryEdges = collectBoundaryEdges(layout, state)
    let coastlineLoops = collectCoastlineLoops(boundaryEdges)

    drawWaterBands(ctx, coastlineLoops)
  }
  ctx->Canvas2d.lineWidth(1.0)
}

let render = (
  ctx,
  layout,
  ~width,
  ~height,
  ~state: HashTable.t,
  ~noisyEdges=false,
  ~fillNoisyEdges=false,
  ~showWater=false,
) => {
  clear(ctx, ~width, ~height)
  maybeRenderWater(ctx, layout, state, width, height, showWater)
  let hexes = state->Dict.valuesToArray

  switch (noisyEdges, fillNoisyEdges) {
  | (true, true) => {
      hexes->Array.forEach(hex => drawNoisyEdgeFill(ctx, layout, state, hex))
      hexes->Array.forEach(hex => drawBoundaryEdges(ctx, layout, state, hex))
    }
  | (true, false) => {
      hexes->Array.forEach(hex => drawHexFill(ctx, layout, hex))
      hexes->Array.forEach(hex => drawBoundaryEdges(ctx, layout, state, hex))
    }
  | (false, _) => hexes->Array.forEach(hex => drawHex(ctx, layout, hex))
  }
}

@react.component
let make = () => {
  let canvasRef = React.useRef(Nullable.null)
  let layout = Models.Layout.make(
    Orientation.pointy,
    Point.make(30.0, 30.0),
    Point.make(400.0, 300.0),
  )

  let (state: HashTable.t, setState) = React.useState(_ => HashTable.make())

  let (controlState, dispatch) = useToggleReducer()

  let handleClick = e => {
    let native = nativeEvent(e)
    let point = Point.make(offsetX(native)->Int.toFloat, offsetY(native)->Int.toFloat)
    let hex = Layout.pixelToHex(layout, point)->Layout.hexRound
    setState(prev => {
      let next = Dict.fromArray(prev->Dict.toArray)
      switch HashTable.get(next, hex) {
      | Some(_) => next->HashTable.remove(hex)
      | None => next->HashTable.insert(hex)
      }
    })
  }

  let dpr = devicePixelRatio
  let (width, height) = (800.0, 600.0)

  let controls: array<(MapControlState.action, bool, string)> = [
    (NoisyEdges, controlState.noisyEdges, "Noisy Edges"),
    (FillNoisyEdges, controlState.fillNoisyEdges, "Fill Noisy Edges"),
    (ShowWater, controlState.showWater, "Show Water"),
  ]

  React.useEffect(() => {
    canvasRef.current
    ->Nullable.toOption
    ->Option.forEach(canvas => {
      let ctx = canvas->CanvasElement.getContext2d
      ctx->Canvas2d.setTransform(~m11=dpr, ~m12=0.0, ~m21=0.0, ~m22=dpr, ~dx=0.0, ~dy=0.0)
      render(
        ctx,
        layout,
        ~width,
        ~height,
        ~state,
        ~noisyEdges=controlState.noisyEdges,
        ~fillNoisyEdges=controlState.fillNoisyEdges,
        ~showWater=controlState.showWater,
      )
    })
    None
  }, (state, controlState.noisyEdges, controlState.fillNoisyEdges, controlState.showWater))

  <>
    <div className="pb-3">
      <div className="flex justify-center space-x-4 mb-3">
        {controls
        ->Array.map(((action, checked, label)) =>
          <label className="flex items-center space-x-2" key={label}>
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
    </div>

    <canvas
      ref={ReactDOM.Ref.domRef(canvasRef)}
      width={(width * dpr)->Float.toString}
      height={(height * dpr)->Float.toString}
      className="w-[800px] h-[600px] border border-blue-500 m-auto flex"
      onClick={handleClick}
    />
  </>
}

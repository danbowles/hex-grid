open Webapi.Canvas
open Models
open Reducers
// module HexHashTable = Models__HexHashTable

@scope("window") @val external devicePixelRatio: float = "devicePixelRatio"

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
  ctx->Canvas2d.setStrokeStyle(String, "#1d4ed8")
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
  ctx->Canvas2d.setFillStyle(String, "#93c5fd")
  ctx->Canvas2d.fill
  ctx->Canvas2d.setStrokeStyle(String, "#1d4ed8")
  ctx->Canvas2d.stroke
}

let drawBoundaryEdges = (ctx, layout, state: HashTable.t, hex) => {
  let corners = Layout.polygonCorners(layout, hex)
  let neighbors = Hexagon.hexNeighbors(hex)
  ctx->Canvas2d.setStrokeStyle(String, "#1d4ed8")
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

let render = (
  ctx,
  layout,
  ~width,
  ~height,
  ~state: HashTable.t,
  ~noisyEdges=false,
  ~fillNoisyEdges=false,
) => {
  clear(ctx, ~width, ~height)
  let hexes = state->Dict.valuesToArray
  switch (noisyEdges, fillNoisyEdges) {
  | (true, true) => hexes->Array.forEach(hex => drawNoisyEdgeFill(ctx, layout, state, hex))
  // hexes->Array.forEach(hex => drawHexFill(ctx, layout, hex))
  // hexes->Array.forEach(hex => drawBoundaryEdges(ctx, layout, state, hex))
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
      )
    })
    None
  }, (state, controlState.noisyEdges, controlState.fillNoisyEdges))

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

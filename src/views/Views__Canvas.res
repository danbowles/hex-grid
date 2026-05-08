open Webapi.Canvas
open Models
module HexHashTable = Models__HexHashTable

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

let render = (ctx, layout, ~width, ~height, ~state: HexHashTable.t) => {
  clear(ctx, ~width, ~height)
  state->Dict.valuesToArray->Array.forEach(hex => drawHex(ctx, layout, hex))
}

@react.component
let make = () => {
  let canvasRef = React.useRef(Nullable.null)
  let layout = Models.Layout.make(
    Orientation.pointy,
    Point.make(30.0, 30.0),
    Point.make(400.0, 300.0),
  )

  let (state: HexHashTable.t, setState) = React.useState(_ => HexHashTable.make())

  let handleClick = e => {
    let native = nativeEvent(e)
    let point = Point.make(offsetX(native)->Int.toFloat, offsetY(native)->Int.toFloat)
    let hex = Layout.pixelToHex(layout, point)->Layout.hexRound
    setState(prev => {
      let next = Dict.fromArray(prev->Dict.toArray)
      switch HexHashTable.get(next, hex) {
      | Some(_) => next->HexHashTable.remove(hex)
      | None => next->HexHashTable.insert(hex)
      }
    })
  }

  let dpr = devicePixelRatio
  let (width, height) = (800.0, 600.0)

  React.useEffect1(() => {
    canvasRef.current
    ->Nullable.toOption
    ->Option.forEach(canvas => {
      let ctx = canvas->CanvasElement.getContext2d
      ctx->Canvas2d.setTransform(~m11=dpr, ~m12=0.0, ~m21=0.0, ~m22=dpr, ~dx=0.0, ~dy=0.0)
      render(ctx, layout, ~width, ~height, ~state)
    })
    None
  }, [state])

  <canvas
    ref={ReactDOM.Ref.domRef(canvasRef)}
    width={(width * dpr)->Float.toString}
    height={(height * dpr)->Float.toString}
    className="w-[800px] h-[600px] border border-blue-500"
    onClick={handleClick}
  />
}

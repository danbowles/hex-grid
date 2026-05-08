open Webapi.Canvas
open Models

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

let render = (ctx, layout, ~width, ~height, ~state) => {
  clear(ctx, ~width, ~height)
  state->Array.forEach(hex => drawHex(ctx, layout, hex))
}

@react.component
let make = () => {
  let canvasRef = React.useRef(Nullable.null)
  let layout = Models.Layout.make(Orientation.pointy, Point.make(30.0, 30.0), Point.make(400.0, 300.0))

  let (state: array<Models.Hexagon.t>, setState) = React.useState(_ => [])

  let handleClick = e => {
    let native = nativeEvent(e)
    let point = Point.make(offsetX(native)->Int.toFloat, offsetY(native)->Int.toFloat)
    let hex = Layout.pixelToHex(layout, point)->Layout.hexRound
    setState(_ => [hex])
  }

  React.useEffect1(() => {
    canvasRef.current
    ->Nullable.toOption
    ->Option.forEach(canvas => {
      let ctx = canvas->CanvasElement.getContext2d
      render(ctx, layout, ~width=800.0, ~height=600.0, ~state)
    })
    None
  }, [state])

  <div className="border border-blue-500">
    <canvas ref={ReactDOM.Ref.domRef(canvasRef)} width="800" height="600" onClick={handleClick} />
  </div>
}

open Webapi.Canvas
open RescriptCore.Console

module Canvas = {
  let clear = (ctx, ~width, ~height) => {
    ctx->Canvas2d.setFillStyle(String, "white")
    ctx->Canvas2d.fillRect(~x=0.0, ~y=0.0, ~w=width, ~h=height)
  }

  // let drawHex = (ctx, ~x, ~y, ~size) => {
  // }

  let render = (ctx, ~width, ~height, ~state) => {
    clear(ctx, ~width, ~height)
  }
}

@react.component
let make = () => {
  let canvasRef = React.useRef(Nullable.null)

  React.useEffect(() => {
    canvasRef.current
    ->Nullable.toOption
    ->Option.forEach(canvas => {
      let ctx = canvas->CanvasElement.getContext2d
      ignore(ctx)
    })
    None
  }, ())

  <div className="border border-blue-500">
    <canvas ref={ReactDOM.Ref.domRef(canvasRef)} width="800" height="600" />
  </div>
}

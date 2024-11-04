module HexText = {
  @react.component
  let make = (~q, ~r, ~s, ~x, ~y) => {
    let style = ReactDOM.Style.make(
      ~fontSize="3px",
      ~fontFamily="monospace",
      ~pointerEvents="none",
      (),
    )
    let text = switch (q, r, s) {
    | (0, 0, 0) => "q,r,s"
    | _ => `${q->Int.toString},${r->Int.toString},${s->Int.toString}`
    }->React.string

    let textFill = switch (q, r, s) {
    | (0, r, s) if r != 0 && s != 0 => "fill-red-500"
    | (q, 0, s) if q != 0 && s != 0 => "fill-green-500"
    | (q, r, 0) if q != 0 && r != 0 => "fill-blue-500"
    | _ => "fill-black"
    }
    <text
      style
      textAnchor="middle"
      x={x->Float.toString}
      y={(y +. 1.5)->Float.toString}
      className={textFill}>
      {text}
    </text>
  }
}

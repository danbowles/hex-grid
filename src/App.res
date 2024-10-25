open Models

module HexText = {
  @react.component
  let make = (~q, ~r, ~s, ~x, ~y) => {
    let style = ReactDOM.Style.make(
      ~fontSize="4px",
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

module Hexagon = {
  @react.component
  let make = (~layout: Layout.t, ~q=0, ~r=0, ~s=0) => {
    let hex = Hex.make(q, r, s)
    let hexCorners = layout->Layout.polygonCorners(hex)
    let pointsString = Js.Array.map(
      (p: Point.tFloat) => `${p.x->Float.toString},${p.y->Float.toString}`,
      hexCorners,
    )
    let {x, y} = layout->Layout.hexToPixel(hex)

    let hexFill = switch (q, r, s) {
    | (0, r, s) if r != 0 && s != 0 => "fill-red-100"
    | (q, 0, s) if q != 0 && s != 0 => "fill-green-100"
    | (q, r, 0) if q != 0 && r != 0 => "fill-blue-100"
    | _ => "fill-slate-50"
    }

    let classNames = `fill-white stroke-slate-300 ${hexFill}`

    <>
      <polygon className={classNames} points={Js.Array.joinWith(",", pointsString)} />
      <g>
        // Debug
        // <circle cx={x->Float.toString} cy={y->Float.toString} r="1" className="fill-red-500" />
        <HexText q r s x y />
      </g>
    </>
  }
}

module HexGridMap = {
  @react.component
  let make = (~q1, ~q2, ~r1, ~r2) => {
    let hexMap = HexMap.make()
    let size = Point.makeFloat(10.0, 10.0)
    let origin = Point.makeFloat(size.x, size.y *. Math.sqrt(3.0) /. 2.0)
    let layout = Layout.make(Orientation.pointy, size->Point.toInt, origin)

    for q in q1 to q2 {
      for r in r1 to r2 {
        let s = -q - r
        let hex = Hex.make(q, r, s)
        hexMap->HexMap.insert(hex)
      }
    }

    let hexes = hexMap->Dict.valuesToArray
    {hexes->Array.map(({q, r, s}) => <Hexagon layout q r s />)->React.array}
  }
}

@react.component
let make = () => {
  <div className="p-6">
    <h1 className="text-3xl font-semibold"> {"Hexagon Grid Creation"->React.string} </h1>
    <p> {React.string("The goal here is to create a hex-grid using ReScript and React.")} </p>
    <a
      href="https://www.redblobgames.com/grids/hexagons/" target="_blank" className="text-blue-500">
      {React.string("Reference")}
    </a>
    <hr className="mb-4 mt-4 fill" />
    <svg viewBox="0 0 200 200" className="border-2 border-sky-900">
      <HexGridMap q1={-3} q2={3} r1={-3} r2={3} />
      // <Hexagon layout />
      // <Hexagon layout q=1 r={-1} s=0 />
      // <Hexagon layout q=2 r={-2} s=0 />
      // <Hexagon layout q={-1} r={1} s=0 />
      // <Hexagon layout q={-2} r={2} s=0 />
      // <Hexagon layout q={-1} r={0} s={1} />
      // <Hexagon layout q={-1} r={-1} s={2} />
      // <Hexagon layout q={-1} r={-2} s={3} />
    </svg>
  </div>
}

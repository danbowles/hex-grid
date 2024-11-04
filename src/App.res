open Models
open HexText

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
    | (0, r, s) if r != 0 && s != 0 => "fill-rose-100"
    | (q, 0, s) if q != 0 && s != 0 => "fill-green-100"
    | (q, r, 0) if q != 0 && r != 0 => "fill-blue-100"
    | _ => "fill-slate-50"
    }

    let classNames = `stroke-slate-300 ${hexFill}`

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

module Parallelogram = {
  @react.component
  let make = (~size, ~direction: ParallelogramMap.direction) => {
    let parallelogramMap = ParallelogramMap.make(size, direction)
    let size = Point.makeFloat(10.0, 10.0)
    let origin = Point.makeFloat(size.x, size.y *. Math.sqrt(3.0) /. 2.0)
    let layout = Layout.make(Orientation.pointy, size->Point.toInt, origin)

    let hexes = ParallelogramMap.toArray(parallelogramMap)
    {hexes->Array.map(({q, r, s}) => <Hexagon layout q r s />)->React.array}
  }
}

@react.component
let make = () => {
  <div className="p-6">
    <h1 className="text-3xl font-semibold"> {"Hexagon Grid Creation"->React.string} </h1>
    <p> {React.string("The goal here is to create a hex-grid using ReScript and React.")} </p>
    <a
      href="https://www.redblobgames.com/grids/hexagons/"
      target="_blank"
      className="text-blue-500 fill-r">
      {React.string("Reference")}
    </a>
    <hr className="mb-4 mt-4 fill" />
    <div className="flex gap-x-2">
      <figure className="border-2 border-sky-900 flex-1">
        <svg viewBox="-80 -60 200 200">
          <Parallelogram size={3} direction={ParallelogramMap.LeftRight} />
        </svg>
      </figure>
      <figure className="border-2 border-sky-900 flex-1">
        <svg viewBox="-80 -60 200 200">
          <Parallelogram size={3} direction={ParallelogramMap.TopBottom} />
        </svg>
      </figure>
      <figure className="border-2 border-sky-900 flex-1">
        <svg viewBox="-80 -60 200 200">
          <Parallelogram size={3} direction={ParallelogramMap.LeftRight} />
        </svg>
      </figure>
    </div>
  </div>
}

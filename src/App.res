open Models
open HexText

type svgRect = {
  x: float,
  y: float,
  width: float,
  height: float,
}
@send external getBBox: (Dom.element) => svgRect = "getBBox"

module Figure = {
  @react.component
  let make = (~children) => {
    <figure className="border-4 border-indigo-200 rounded-lg mb-6">
      {children}
    </figure>
  }
}

module Hexagon = {
  @react.component
  let make = (~layout: Layout.t, ~q=0, ~r=0, ~s=0) => {
    let style = ReactDOM.Style.make(~strokeWidth="0.3", ())
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

    let classNames = `stroke-slate-500 ${hexFill}`

    <>
      <polygon className={classNames} points={Js.Array.joinWith(",", pointsString)} style={style} />
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
    hexes->Array.map(hex => {
      let {q, r, s} = hex
      let key = hex->Hex.toString
      <Hexagon key layout q r s />
    })->React.array
  }
}

module HexagonGrid = {
  @react.component
  let make = (~size) => {
    let hexMap = HexagonalMap.make(size)
    let size = Point.makeFloat(10.0, 10.0)
    let origin = Point.makeFloat(size.x, size.y *. Math.sqrt(3.0) /. 2.0)
    let layout = Layout.make(Orientation.pointy, size->Point.toInt, origin)

    let hexes = HexagonalMap.toArray(hexMap)
    hexes->Array.map(hex => {
      let {q, r, s} = hex
      let key = hex->Hex.toString
      <Hexagon key layout q r s />
    })->React.array
  }
}

module Svg = {
  module Group = {
  @react.component
  let make = (~children, ~setGroupRef=?) => {
    let setGroupRef = element => {
    switch setGroupRef {
    | Some(setGroupRef) => setGroupRef(element)
    | None => ()
    }
  }
    <g ref={ReactDOM.Ref.callbackDomRef(setGroupRef)}>
      {children}
    </g>
  }
}
  @react.component
  let make = (~children) => {
    let innerPadding = 2.0
    let (viewBox, setViewBox) = React.useState(() => "-80 -60 200 200")
  let handleGroupRef = el => {
    switch el->Nullable.toOption {
    | Some(el) => {
      let {x, y, width, height} = el->getBBox
      // Oof.  Likely a better way to do this.
      setViewBox(_ => `${(x-.innerPadding)->Float.toString} ${(y-.innerPadding)->Float.toString} ${(width+.(innerPadding*.2.0))->Float.toString}  ${(height+.(innerPadding*.2.0))->Float.toString}`)
    }
    | None => ()
    }
  }
    <svg viewBox>
      <Group setGroupRef={handleGroupRef}>
      {children}
      </Group>
    </svg>
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
    <div>
      <h2 className="text-2xl mb-2">{"Parallelogram Map"->React.string}</h2>
      <Figure>
        <Svg>
          <Parallelogram size={6} direction={ParallelogramMap.LeftRight} />
        </Svg>
      </Figure>
    </div>
    <div>
      <h2 className="text-2xl mb-2">{"Hexagon"->React.string}</h2>
      <Figure>
        <Svg>
          <HexagonGrid size={6} />
        </Svg>
      </Figure>
    </div>
  </div>
}

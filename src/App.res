open Models
open HexText
open Figure
open FigureWithControls
open Svg

type mapType =
  | Parallelogram
  | Hexagon

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

module HexagonGrid = {
  @react.component
  let make = (~size) => {
    let hexMap = HexagonalMap.make(size)
    let size = Point.makeFloat(10.0, 10.0)
    let origin = Point.makeFloat(size.x, size.y *. Math.sqrt(3.0) /. 2.0)
    let layout = Layout.make(Orientation.pointy, size->Point.toInt, origin)

    let hexes = HexagonalMap.toArray(hexMap)
    hexes
    ->Array.map(hex => {
      let {q, r, s} = hex
      let key = hex->Hex.toString
      <Hexagon key layout q r s />
    })
    ->React.array
  }
}

module ParallelogramGrid = {
  @react.component
  let make = (~size, ~direction: ParallelogramMap.direction) => {
    let parallelogramMap = ParallelogramMap.make(size, direction)
    let size = Point.makeFloat(10.0, 10.0)
    let origin = Point.makeFloat(size.x, size.y *. Math.sqrt(3.0) /. 2.0)
    let layout = Layout.make(Orientation.pointy, size->Point.toInt, origin)

    let hexes = ParallelogramMap.toArray(parallelogramMap)
    hexes
    ->Array.map(hex => {
      let {q, r, s} = hex
      let key = hex->Hex.toString
      <Hexagon key layout q r s />
    })
    ->React.array
  }
}

module Map = {
  @react.component
  let make = (~mapType: mapType, ~size, ~newProp=?) => {
    Js.log(newProp)
    <Svg>
      {switch mapType {
      | Parallelogram => <ParallelogramGrid size direction={ParallelogramMap.LeftRight} />
      | Hexagon => <HexagonGrid size />
      }}
    </Svg>
  }
}

@react.component
let make = () => {
  <div className="w-full max-w-screen-xl mx-auto mt-8 mb-8 pl-5 pr-5">
    <div className="flex justify-start items-center mb-8 flex-col md:flex-row">
      <div>
        <h1 className="text-4xl font-bold"> {"Hexagon Grid Creator"->React.string} </h1>
        <p className="text-lg text-gray-600">
          {"Create and visualize hexagonal grids with ease"->React.string}
        </p>
      </div>
      <div className="flex flex-wrap space-x-4 m-0 mt-4 md:ml-auto">
        <a href="https://www.redblobgames.com/grids/hexagons/" target="_blank" className="text-blue-500 hover:underline">
          {React.string("Reference")}
        </a>
        <a href="https://rescript-lang.org/" target="_blank" className="text-blue-500 hover:underline">
          {React.string("ReScript")}
        </a>
        <a href="https://reactjs.org/" target="_blank" className="text-blue-500 hover:underline">
          {React.string("React")}
        </a>
        <a href="#" target="_blank" className="text-blue-500 hover:underline">
          {React.string("GitHub Repo")}
        </a>
      </div>
    </div>
    <hr className="my-8 border-t-2 border-gray-300" />
    <div className="grid grid-cols-2 gap-4">
      <Figure caption="Parallelogram Map">
        <Map mapType={Parallelogram} size={6} />
      </Figure>
      <Figure caption="Hexagon Map">
        <Map mapType={Hexagon} size={6} />
      </Figure>
      <FigureWithControls caption="Hexagon Map">
        <Svg>
          <HexagonGrid size={6} />
        </Svg>
      </FigureWithControls>
    </div>
  </div>
}

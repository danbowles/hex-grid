open Contexts
open Figure
open HexText
open FigureWithControls
open Models
open Svg

module SvgHexagon = {
  @react.component
  let make = (~hex: Hexagon.t, ~isActive=false, ~neighbors, ~setActiveHex) => {
    let {showColors, showDebugCircle, showCoords, highlightNeighbors} = ControlsContext.useContext()
    let layout = LayoutContext.useContext()
    let {q, r, s} = hex
    let {x, y} = layout->Layout.hexToPixel(hex)
    let points = layout->Layout.polygonCorners(hex)->Array.map(Point.toString)->Array.join(",")
    let className = "stroke-slate-500"

    let onMouseEnter = highlightNeighbors ? _ => setActiveHex(_ => Some(hex)) : _ => ()
    let onMouseLeave = highlightNeighbors ? _ => setActiveHex(_ => None) : _ => ()

    let hexFill = switch (q, r, s) {
    | (0, r, s) if r != 0 && s != 0 => "fill-rose-100"
    | (q, 0, s) if q != 0 && s != 0 => "fill-green-100"
    | (q, r, 0) if q != 0 && r != 0 => "fill-blue-100"
    | _ => "fill-slate-50"
    }

    let hexFill = switch (
      neighbors->Array.find(((h, _)) => h->Hexagon.hexAreEqual(hex)),
      showColors,
    ) {
    | (Some((_, color)), _) => color
    | (None, true) => hexFill
    | (_, false) => "fill-slate-50"
    }
    let className = `${className} ${hexFill}`

    <>
      <polygon
        className
        points
        style={ReactDOM.Style.make(~strokeWidth="0.3", ())}
        onMouseEnter
        onMouseLeave
      />
      <g>
        {showDebugCircle
          ? <circle cx={x->Float.toString} cy={y->Float.toString} r="1" className="fill-red-500" />
          : <> </>}
        {showCoords ? <HexText q r s x y /> : <> </>}
      </g>
    </>
  }
}
let colors = list{
  "fill-red-300",
  "fill-orange-300",
  "fill-yellow-300",
  "fill-green-300",
  "fill-blue-300",
  "fill-indigo-300",
  "fill-purple-300",
  "fill-pink-300",
}
let useNeighbors = (
  ~activeHex: option<Hexagon.t>,
  ~colors: list<string>=colors,
  ~levels: int=4,
) => {
  switch (activeHex, levels) {
  | (None, _) => Array.make(~length=levels, [])
  | (Some(hex), 0) => Array.make(~length=0, [hex])
  | (Some(hex), levels) => {
      let visited = Set.make()
      let result = []

      let rec findNeighbors = (currentLevel, level) => {
        if level > levels {
          ()
        } else {
          let nextLevel = []

          currentLevel->Array.forEach(hex => {
            let neighbors = hex->Hexagon.hexNeighbors
            neighbors->Array.forEach(n => {
              switch visited->Set.has(Hexagon.toString(n)) {
              | true => ()
              | false => {
                  visited->Set.add(Hexagon.toString(n))
                  nextLevel->Array.push(n)
                }
              }
            })
          })

          if nextLevel->Array.length > 0 {
            result->Array.push(nextLevel)
            findNeighbors(nextLevel, level + 1)
          }
        }
      }

      visited->Set.add(Hexagon.toString(hex))
      result->Array.push([hex])
      findNeighbors([hex], 1)

      result
    }
  }
  ->Array.mapWithIndex((neighbors, i) => {
    switch colors->List.get(mod(i, colors->List.length)) {
    | Some(color) => neighbors->Array.map(n => (n, color))
    | None => neighbors->Array.map(n => (n, "fill-slate-50"))
    }
  })
  ->Array.flat
}

module HexagonGrid = {
  @react.component
  let make = (~size) => {
    let (activeHex: option<Hexagon.t>, setActiveHex) = React.useState(_ => None)
    let neighbors: array<(Models.Hexagon.t, string)> = useNeighbors(~activeHex)

    Models.Maps.HexagonalMap.make(size)
    ->Models.Maps.HexagonalMap.toArray
    ->Array.map(hex => {
      let isActive = switch activeHex {
      | Some(activeHex) => Hexagon.hexAreEqual(hex, activeHex)
      | None => false
      }
      <SvgHexagon hex isActive setActiveHex neighbors />
    })
    ->React.array
  }
}

module ParallelogramGrid = {
  @react.component
  let make = (~size, ~direction: Models.Maps.ParallelogramMap.direction) => {
    let (activeHex: option<Hexagon.t>, setActiveHex) = React.useState(_ => None)
    let neighbors: array<(Models.Hexagon.t, string)> = useNeighbors(~activeHex)

    Models.Maps.ParallelogramMap.make(size, direction)
    ->Models.Maps.ParallelogramMap.toArray
    ->Array.map(hex => {
      let isActive = switch activeHex {
      | Some(activeHex) => Hexagon.hexAreEqual(hex, activeHex)
      | None => false
      }

      <SvgHexagon hex isActive setActiveHex neighbors key={hex->Hexagon.toString} />
    })
    ->React.array
  }
}

module RectangularGrid = {
  @react.component
  let make = (~left, ~right, ~top, ~bottom) => {
    let (activeHex: option<Hexagon.t>, setActiveHex) = React.useState(_ => None)
    let neighbors: array<(Models.Hexagon.t, string)> = useNeighbors(~activeHex)

    Models.Maps.RectangularMap.make(~left, ~right, ~top, ~bottom)
    ->Models.Maps.RectangularMap.toArray
    ->Array.map(hex => {
      let isActive = switch activeHex {
      | Some(activeHex) => Hexagon.hexAreEqual(hex, activeHex)
      | None => false
      }
      <SvgHexagon hex isActive setActiveHex neighbors />
    })
    ->React.array
  }
}

module TriangularGrid = {
  @react.component
  let make = (~size) => {
    let (activeHex: option<Hexagon.t>, setActiveHex) = React.useState(_ => None)
    let neighbors: array<(Models.Hexagon.t, string)> = useNeighbors(~activeHex)

    Models.Maps.TriangularMap.make(size)
    ->Models.Maps.TriangularMap.toArray
    ->Array.map(hex => {
      let isActive = switch activeHex {
      | Some(activeHex) => Hexagon.hexAreEqual(hex, activeHex)
      | None => false
      }
      <SvgHexagon hex isActive setActiveHex neighbors />
    })
    ->React.array
  }
}

module MapShapes = {
  @react.component
  let make = () => <>
    <div className="mb-3">
      <p className="md:hidden">
        <HeroIcons.Solid.DevicePhoneMobileIcon className="h-6 w-6 mr-2 inline-block" />
        {"Tap for 'Neighbors' Highlight"->React.string}
      </p>
      <p className="hidden md:block">
        <HeroIcons.Solid.ComputerDesktopIcon className="h-6 w-6 mr-2 inline-block" />
        {"Hover for 'Neighbors' Highlight"->React.string}
      </p>
    </div>
    <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
      <FigureWithControls caption="Parallelogram Map">
        <Svg>
          <ParallelogramGrid size={4} direction={Models.Maps.ParallelogramMap.LeftRight} />
        </Svg>
      </FigureWithControls>
      <FigureWithControls caption="Hexagon Map">
        <Svg>
          <HexagonGrid size={6} />
        </Svg>
      </FigureWithControls>
      <FigureWithControls caption="Rectangular Map">
        <Svg>
          <RectangularGrid left={-5} right={5} top={-4} bottom={4} />
        </Svg>
      </FigureWithControls>
      <FigureWithControls caption="Triangular Map">
        <Svg>
          <TriangularGrid size={12} />
        </Svg>
      </FigureWithControls>
    </div>
  </>
}

module NotFound = {
  @react.component
  let make = () =>
    <div className="flex flex-col items-center justify-center h-screen">
      <h1 className="text-4xl font-bold"> {"404 - Not Found"->React.string} </h1>
      <p className="text-lg"> {"The page you are looking for does not exist"->React.string} </p>
    </div>
}

module About = {
  @react.component
  let make = () =>
    <div className="flex flex-col">
      <h1 className="text-4xl font-bold"> {"About"->React.string} </h1>
      <p className="text-lg"> {"Learn more about Hexagon Grid Creator"->React.string} </p>
    </div>
}

module Pathfinding = {
  @react.component
  let make = () => <Views__Pathfinding />
}

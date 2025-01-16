open Figure
open HexText
open FigureWithControls
open Models
open Svg

module SvgHexagon = {
  @react.component
  let make = (
    ~layout: Layout.t,
    ~hex: Hexagon.t,
    ~showColors,
    ~showCoords,
    ~showDebugCircle,
    ~onMouseEnter,
    ~onMouseLeave,
    ~isActive=false,
    ~isNeighborOfActive=false,
    ~isNeighborOfNeighborOfActive=false,
  ) => {
    let style = ReactDOM.Style.make(~strokeWidth="0.3", ())
    let {q, r, s} = hex
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
    let classNames = "stroke-slate-500"
    let hexFill = switch (showColors, isActive, isNeighborOfActive, isNeighborOfNeighborOfActive) {
    | (_, true, _, _) => "fill-amber-300"
    | (_, _, true, _) => "fill-amber-200"
    | (_, _, _, true) => "fill-amber-100"
    | (true, false, false, false) => hexFill
    | (false, _, _, _) => "fill-slate-50"
    }
    let classNames = `${classNames} ${hexFill}`

    <>
      <polygon
        className={classNames}
        points={Js.Array.joinWith(",", pointsString)}
        style={style}
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

let useNestedNeighbors = (activeHex: option<Hexagon.t>) => {
  let (hexNeighbors, neighborNeighbors) = switch activeHex {
  | None => ([], [])
  | Some(hex) => {
      let neighbors = hex->Hexagon.hexNeighbors
      let neighborNeighbors = neighbors->Array.flatMap(neighbor => neighbor->Hexagon.hexNeighbors)
      let neighborsAndActive = neighbors->Array.concat([hex])
      let neighborNeighbors = neighborNeighbors->Array.filter(nn => {
        switch neighborsAndActive->Array.find(n => Hexagon.hexAreEqual(n, nn)) {
        | Some(_) => false
        | _ => true
        }
      })
      (neighbors, neighborNeighbors)
    }
  }
  (hexNeighbors, neighborNeighbors)
}

let useAllNeighbors = (activeHex: option<Hexagon.t>, levels: int) => {
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
}

let renderHex = (
  ~hex,
  ~activeHex,
  ~neighbors,
  ~neighborNeighbors,
  ~layout,
  ~controlState: MapControlState.state,
  ~setActiveHex,
) => {
  let {showColors, showCoords, showDebugCircle} = controlState
  let key = hex->Hexagon.toString
  let isActive = switch activeHex {
  | Some(activeHex) => Hexagon.hexAreEqual(hex, activeHex)
  | None => false
  }
  let isNeighborOfActive = neighbors->Array.some(neighbor => Hexagon.hexAreEqual(neighbor, hex))
  let isNeighborOfNeighborOfActive =
    neighborNeighbors->Array.some(neighbor => Hexagon.hexAreEqual(neighbor, hex))
  let onMouseEnter = controlState.highlightNeighbors ? _ => setActiveHex(_ => Some(hex)) : _ => ()
  let onMouseLeave = controlState.highlightNeighbors ? _ => setActiveHex(_ => None) : _ => ()
  <SvgHexagon
    key
    layout
    hex
    showColors
    showCoords
    showDebugCircle
    onMouseEnter
    onMouseLeave
    isActive
    isNeighborOfActive
    isNeighborOfNeighborOfActive
  />
}

module HexagonGrid = {
  @react.component
  let make = (~size) => {
    let controlState = ControlsContext.useContext()
    let layout = LayoutContext.useContext()
    let (activeHex: option<Hexagon.t>, setActiveHex) = React.useState(_ => None)
    let (neighbors, neighborNeighbors) = useNestedNeighbors(activeHex)
    let allNeighbors = useAllNeighbors(activeHex, 4)

    let colors = list{
      "fill-red-500",
      "fill-orange-500",
      "fill-yellow-500",
      "fill-green-500",
      "fill-blue-500",
    }

    switch activeHex {
    | Some(hex) if hex->Hexagon.hexAreEqual(Hexagon.make(0, 0, 0)) => {
        let allNeighborsWithColors = allNeighbors->Array.mapWithIndex((neighbors, i) => {
          switch colors->List.get(mod(i, colors->List.length)) {
          | Some(color) => neighbors->Array.map(n => (n, color))
          | None => neighbors->Array.map(n => (n, "fill-slate-50"))
          }
        })
        Js.log((
          "All Neighbors",
          allNeighbors->Array.mapWithIndex((neighbors, i) => (i, neighbors->Array.length)),
          allNeighborsWithColors->Array.flat,
        ))
      }
    | _ => ()
    }

    Models.Maps.HexagonalMap.make(size)
    ->Models.Maps.HexagonalMap.toArray
    ->Array.map(hex => {
      renderHex(
        ~hex,
        ~activeHex,
        ~neighbors,
        ~neighborNeighbors,
        ~layout,
        ~controlState,
        ~setActiveHex,
      )
    })
    ->React.array
  }
}

module ParallelogramGrid = {
  @react.component
  let make = (~size, ~direction: Models.Maps.ParallelogramMap.direction) => {
    let controlState = ControlsContext.useContext()
    let layout = LayoutContext.useContext()
    let (activeHex: option<Hexagon.t>, setActiveHex) = React.useState(_ => None)
    let (neighbors, neighborNeighbors) = useNestedNeighbors(activeHex)

    Models.Maps.ParallelogramMap.make(size, direction)
    ->Models.Maps.ParallelogramMap.toArray
    ->Array.map(hex => {
      renderHex(
        ~hex,
        ~activeHex,
        ~neighbors,
        ~neighborNeighbors,
        ~layout,
        ~controlState,
        ~setActiveHex,
      )
    })
    ->React.array
  }
}

module RectangularGrid = {
  @react.component
  let make = (~left, ~right, ~top, ~bottom) => {
    let controlState = ControlsContext.useContext()
    let layout = LayoutContext.useContext()
    let (activeHex: option<Hexagon.t>, setActiveHex) = React.useState(_ => None)
    let (neighbors, neighborNeighbors) = useNestedNeighbors(activeHex)

    Models.Maps.RectangularMap.make(~left, ~right, ~top, ~bottom)
    ->Models.Maps.RectangularMap.toArray
    ->Array.map(hex => {
      renderHex(
        ~hex,
        ~activeHex,
        ~neighbors,
        ~neighborNeighbors,
        ~layout,
        ~controlState,
        ~setActiveHex,
      )
    })
    ->React.array
  }
}

module TriangularGrid = {
  @react.component
  let make = (~size) => {
    let controlState = ControlsContext.useContext()
    let layout = LayoutContext.useContext()
    let (activeHex: option<Hexagon.t>, setActiveHex) = React.useState(_ => None)
    let (neighbors, neighborNeighbors) = useNestedNeighbors(activeHex)

    Models.Maps.TriangularMap.make(size)
    ->Models.Maps.TriangularMap.toArray
    ->Array.map(hex => {
      renderHex(
        ~hex,
        ~activeHex,
        ~neighbors,
        ~neighborNeighbors,
        ~layout,
        ~controlState,
        ~setActiveHex,
      )
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
          <TriangularGrid size={8} />
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
    <div className="flex flex-col items-center justify-center h-screen">
      <h1 className="text-4xl font-bold"> {"About"->React.string} </h1>
      <p className="text-lg"> {"Learn more about Hexagon Grid Creator"->React.string} </p>
    </div>
}

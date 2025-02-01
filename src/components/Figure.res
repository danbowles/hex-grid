open Contexts
open Reducers
open Models
open Svg

module TerrainMap = Maps.TerrainMap

// module WaterTexture = {
//   @react.component
//   let make = (~points, ~x, ~y) => {
//     <>
//       <defs>
//         <clipPath id="hexagonClip">
//           <polygon points />
//         </clipPath>
//         <filter
//           id="water"
//           x={x->Float.toString}
//           y={y->Float.toString}
//           width="100%"
//           height="100%"
//           filterUnits="objectBoundingBox"
//           primitiveUnits="userSpaceOnUse"
//           colorInterpolationFilters="linearRGB">
//           <feTurbulence
//             type_="fractalNoise"
//             baseFrequency="0.05"
//             numOctaves="4"
//             seed="15"
//             stitchTiles="stitch"
//             x={x->Float.toString}
//             y={y->Float.toString}
//             width="100%"
//             height="100%"
//             result="turbulence"
//           />
//           <feSpecularLighting
//             surfaceScale="5"
//             specularConstant="1.8"
//             specularExponent="20"
//             lightingColor="#4a90e2"
//             x={x->Float.toString}
//             y={y->Float.toString}
//             width="100%"
//             height="100%"
//             in_="turbulence"
//             result="specularLighting">
//             <feDistantLight azimuth="3" elevation="90" />
//           </feSpecularLighting>
//         </filter>
//       </defs>
//       // <g clipPath="url(#hexagonClip)">
//       <polygon points fill="lightblue" />
//       // <rect
//       //   x="0"
//       //   y="0"
//       //   width="100"
//       //   height="100"
//       //   // clipPath="url(#hexagonClip)"
//       // />
//       <rect width="700" height="700" />
//       // </g>
//       // <rect width="700" height="700" fill="#ffffff00" />
//     </>
//   }
// }

module EmptyGrid = {
  @react.component
  let make = (~terrainMap: Maps.TerrainMap.t, ~onDrawTerrain) => {
    let dragging = DraggingContext.useContext()
    let layout = LayoutContext.useContext()
    let style = ReactDOM.Style.make(~strokeWidth="0.1", ())

    let handleMouseEnter = hex => {
      if dragging {
        onDrawTerrain(hex)
      }
    }

    terrainMap.hashTable
    ->Dict.valuesToArray
    ->Array.map(hexWithTerrain => {
      let key = hexWithTerrain.hex->Models.Hexagon.toString
      let hexCorners = layout->Layout.polygonCorners(hexWithTerrain.hex)
      let points = hexCorners->Array.map(Point.toString)->Array.join(",")
      <polygon
        onClick={_ => onDrawTerrain(hexWithTerrain.hex)}
        onMouseEnter={_ => handleMouseEnter(hexWithTerrain.hex)}
        key
        className={`stroke-slate-900 ${hexWithTerrain.terrain.fillColor}`}
        points
        style
      />
    })
    ->React.array
  }
}

module MapMakerFigure = {
  @react.component
  let make = () => {
    let terrains: array<Models.Terrain.kind> = [Water, Grass, Mountain, Sand, Clear]
    let (activeTerrain: option<Models.Terrain.kind>, setActiveTerrain) = React.useState(() =>
      terrains->Array.get(0)
    )
    let (terrainMap, setTerrainMap) = React.useState(() => TerrainMap.make(~height=18, ~width=20))

    let onDrawTerrain = hex => {
      setTerrainMap(_ => {
        let table = switch activeTerrain {
        | Some(terrain) =>
          terrainMap.hashTable->TerrainMap.TerrainMapHashTable.updateTerrain(hex, terrain)
        | None => terrainMap.hashTable->TerrainMap.TerrainMapHashTable.updateTerrain(hex, Clear)
        }

        {hashTable: table}
      })
    }
    let onFillMapClick = () => {
      setTerrainMap(_ => {
        let table = switch activeTerrain {
        | Some(terrain) =>
          terrainMap.hashTable->TerrainMap.TerrainMapHashTable.fillMapWithTerrain(terrain)
        | None => terrainMap.hashTable->TerrainMap.TerrainMapHashTable.fillMapWithTerrain(Clear)
        }
        {hashTable: table}
      })
    }

    <figure>
      <LayoutContext.Provider value={LayoutContext.layout}>
        <div className="flex space-x-2">
          {terrains
          ->Array.map(Models.Terrain.make)
          ->Array.map(terrain =>
            <button
              key={terrain.kind->Models.Terrain.kindToString}
              onClick={_ => setActiveTerrain(_ => Some(terrain.kind))}
              className={[
                Some(terrain.kind) === activeTerrain ? "" : "opacity-50",
                terrain.bgColor,
                terrain.textColor,
                "p-2  border-black border",
              ]->Array.join(" ")}>
              {terrain.kind->Models.Terrain.kindToString->React.string}
            </button>
          )
          ->React.array}
          <div className="border-l-8 border-l-white" />
          <button
            onClick={_ => onFillMapClick()}
            className="p-2 border-black border flex items-center space-x-2">
            <HeroIcons__Solid.PaintBrushIcon
              className={"h-5 w-5 " ++
              switch activeTerrain {
              | Some(Clear) => "text-gray-700"
              | Some(k) => k->Models.Terrain.getFillColor
              | _ => "text-gray-700"
              }}
            />
            <span> {"Fill"->React.string} </span>
          </button>
        </div>
        <Svg>
          <EmptyGrid terrainMap onDrawTerrain />
        </Svg>
      </LayoutContext.Provider>
    </figure>
  }
}

module FigureWithControls = {
  @react.component
  let make = (~caption=?, ~children) => {
    let (state, dispatch) = useToggleReducer()
    let controls: array<(MapControlState.action, bool, string)> = [
      (ShowColors, state.showColors, "Colors"),
      (ShowDebugCircle, state.showDebugCircle, "Debug"),
      (ShowCoords, state.showCoords, "Coords"),
      (HighlightNeighbors, state.highlightNeighbors, "Neighbors"),
    ]
    <figure className="flex flex-col shadow-lg border border-blue-700 rounded overflow-hidden">
      {switch caption {
      | Some(caption) =>
        <figcaption className="bg-blue-700 text-white text-xl font-mono font-bold p-4">
          {caption->React.string}
        </figcaption>
      | None => <> </>
      }}
      <div className="p-2">
        <div className="flex justify-center space-x-4 mb-3">
          {controls
          ->Array.map(((action, checked, label)) =>
            <label className="flex items-center space-x-2" key={label}>
              <input
                type_="checkbox"
                className="form-checkbox h-4 w-4 text-blue-600"
                checked
                onChange={_ => dispatch(action)}
                key={label}
              />
              <span className="text-gray-800 text-sm"> {label->React.string} </span>
            </label>
          )
          ->React.array}
        </div>
        <div className="">
          <LayoutContext.Provider value={LayoutContext.layout}>
            <ControlsContext.Provider value={state}> {children} </ControlsContext.Provider>
          </LayoutContext.Provider>
        </div>
      </div>
    </figure>
  }
}

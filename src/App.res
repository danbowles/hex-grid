open Figure
open Footer
open Header
open Models
open Svg

module MapMaker = {
  module EmptyGrid = {
    @react.component
    let make = (~height, ~width) => {
      let drawing = Svg.DrawingContext.useContext()
      let layout = LayoutContext.useContext()

      let handleMouseEnter = _ => {
        if drawing {
          Js.log("Drawing")
        }
      }

      let tMap = TerrainMap.make(~height, ~width)
      Js.log(tMap.hashTable->TerrainMap.TerrainMapHashTable.get(Hex.make(0, 0, 0)))
      // tMap.hashTable->TerrainMap.TerrainMapHashTable.insert(Hex.make(0, 0, 0), Terrain.water)
      // Js.log(tMap.hashTable->TerrainMap.TerrainMapHashTable.get(Hex.make(0, 0, 0)))

      tMap.hashTable
      ->Dict.valuesToArray
      ->Array.map(hexWithTerrain => {
        let key = hexWithTerrain.hex->Hex.toString
        let style = ReactDOM.Style.make(~strokeWidth="0.3", ())
        let hexCorners = layout->Layout.polygonCorners(hexWithTerrain.hex)
        let pointsString = Js.Array.map(
          (p: Point.tFloat) => `${p.x->Float.toString},${p.y->Float.toString}`,
          hexCorners,
        )
        <polygon
          onMouseEnter={handleMouseEnter}
          key
          className={`stroke-slate-500 ${hexWithTerrain.terrain.fillColor}`}
          points={Js.Array.joinWith(",", pointsString)}
          style={style}
        />
      })
      ->React.array
    }
  }

  @react.component
  let make = () =>
    <MapMakerFigure>
      <Svg>
        <EmptyGrid height={10} width={10} />
      </Svg>
    </MapMakerFigure>
}

@react.component
let make = () => {
  let route = Router.useRouter()
  <div className="flex flex-col min-h-screen w-full max-w-screen-xl mx-auto">
    <Header />
    <main className="flex-grow p-4">
      {switch route {
      | Some(MapShapes) => <Views.MapShapes />
      | Some(MapMaker) => <MapMaker />
      | Some(About) => <Views.About />
      | None => <Views.NotFound />
      }}
    </main>
    <Footer />
  </div>
}

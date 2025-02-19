open Figure
open Footer
open Header

module MapMaker = {
  @react.component
  let make = () => <MapMakerFigure />
}

@react.component
let make = () => {
  let route = Router.useRouter()
  <div className="flex flex-col min-h-screen w-full max-w-screen-xl mx-auto">
    <Header />
    <main className="flex-grow p-4">
      {switch route {
      | Some(MapShapes) => <Views.MapShapes />
      | Some(Pathfinding) => <Views.Pathfinding />
      | Some(MapMaker) => <MapMaker />
      | Some(MapNoise) => <Views.MapNoise />
      | None => <Views.NotFound />
      }}
    </main>
    <Footer />
  </div>
}

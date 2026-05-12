let baseUrl: string = %raw(`import.meta.env.BASE_URL.replace(/\/$/, "")`)

let buildUrl = (path: string) => baseUrl ++ "/#/" ++ path

type t =
  | Pathfinding
  | MapShapes
  | MapMaker
  | MapNoise
  | Canvas

type group =
  | Layouts
  | Maps
  | Algorithms
  | Rendering

type renderer =
  | Svg
  | Canvas2d
  | Webgl

type experiment = {
  route: t,
  path: string,
  label: string,
  group: group,
  renderer: renderer,
}

let groups = [Layouts, Maps, Algorithms, Rendering]

let groupToString = group =>
  switch group {
  | Layouts => "Layouts"
  | Maps => "Maps"
  | Algorithms => "Algorithms"
  | Rendering => "Rendering"
  }

let rendererToString = renderer =>
  switch renderer {
  | Svg => "SVG"
  | Canvas2d => "Canvas 2D"
  | Webgl => "WebGL"
  }

let routes = [
  {route: MapShapes, path: "", label: "Map Shapes", group: Layouts, renderer: Svg},
  {route: MapMaker, path: "map", label: "Terrain Painter", group: Maps, renderer: Svg},
  {route: MapNoise, path: "noise", label: "Noise Map", group: Maps, renderer: Svg},
  {route: Pathfinding, path: "pathfinding", label: "Pathfinding", group: Algorithms, renderer: Svg},
  {route: Canvas, path: "canvas", label: "Canvas 2D", group: Rendering, renderer: Canvas2d},
]

let routesForGroup = group => routes->Array.filter(experiment => experiment.group == group)

let toString = route =>
  routes
  ->Array.find(experiment => experiment.route == route)
  ->Option.map(experiment => buildUrl(experiment.path))
  ->Option.getOr(buildUrl("/"))

let fromUrl = (url: RescriptReactRouter.url) => {
  let seg = url.hash->String.split("/")->Array.get(1)->Option.getOr("")
  routes->Array.find(experiment => experiment.path == seg)->Option.map(experiment => experiment.route)
}

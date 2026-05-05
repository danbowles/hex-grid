let baseUrl: string = %raw(`import.meta.env.BASE_URL.replace(/\/$/, "")`)

let buildUrl = (path: string) => baseUrl ++ "/#/" ++ path

type t =
  | Pathfinding
  | MapShapes
  | MapMaker
  | MapNoise
  | Canvas

let routes = [
  (MapShapes, "", "Map Shapes"),
  (MapMaker, "map", "Map Maker"),
  (Pathfinding, "pathfinding", "Pathfinding"),
  (MapNoise, "noise", "Map Noise"),
  (Canvas, "canvas", "Canvas"),
]

let toString = route =>
  routes
  ->Array.find(((r, _, _)) => r == route)
  ->Option.map(((_, path, _)) => buildUrl(path))
  ->Option.getOr(buildUrl("/"))

let fromUrl = (url: RescriptReactRouter.url) => {
  let seg = url.hash->String.split("/")->Array.get(1)->Option.getOr("")
  routes->Array.find(((_, path, _)) => path == seg)->Option.map(((r, _, _)) => r)
}

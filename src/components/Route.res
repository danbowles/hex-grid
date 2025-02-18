// TODO: Get this from vite config somehow?
let baseUrl = "/hex-grid"

let buildUrl = (path: string) => baseUrl ++ "/#" ++ path

type t =
  | Pathfinding
  | MapShapes
  | MapMaker
  | MapNoise

let fromUrl = (url: RescriptReactRouter.url) => {
  let hash = url.hash->String.split("/")->List.fromArray
  switch hash {
  | list{_, "pathfinding"} => Pathfinding->Some
  | list{_, "map"} => MapMaker->Some
  | list{_, "noise"} => MapNoise->Some
  | list{_, ""}
  | _ =>
    MapShapes->Some
  }
}

let toString = x =>
  switch x {
  | MapShapes => buildUrl("/")
  | Pathfinding => buildUrl("/pathfinding")
  | MapMaker => buildUrl("/map")
  | MapNoise => buildUrl("/noise")
  }

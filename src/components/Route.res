// TODO: Get this from vite config somehow?
let baseUrl = "/hex-grid"

let buildUrl = (path: string) => baseUrl ++ "/#" ++ path

type t =
  | Pathfinding
  | MapShapes
  | MapMaker
  | About

let fromUrl = (url: RescriptReactRouter.url) => {
  let hash = url.hash->String.split("/")->List.fromArray
  switch hash {
  | list{_, "pathfinding"} => Pathfinding->Some
  | list{_, "map"} => MapMaker->Some
  | list{_, "about"} => About->Some
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
  | About => buildUrl("/about")
  }

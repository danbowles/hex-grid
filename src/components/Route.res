// TODO: Get this from vite config somehow?
let baseUrl = "/hex-grid"

let buildUrl = (path: string) => baseUrl ++ path

type t =
  | Pathfinding
  | MapShapes
  | MapMaker
  | About

let fromUrl = (url: RescriptReactRouter.url) => {
  switch url.path {
  | list{_} => MapShapes->Some
  | list{_, "pathfinding"} => Pathfinding->Some
  | list{_, "map"} => MapMaker->Some
  | list{"hex-grid", "about"} => About->Some
  | _ => None
  }
}

let toString = x =>
  switch x {
  | MapShapes => buildUrl("/")
  | Pathfinding => buildUrl("/pathfinding")
  | MapMaker => buildUrl("/map")
  | About => buildUrl("/about")
  }

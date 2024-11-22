// TODO: Get this from vite config somehow?
let baseUrl = "/hex-grid"

let buildUrl = (path: string) => baseUrl ++ path

type t =
  | MapShapes
  | MapMaker
  | About

let fromUrl = (url: RescriptReactRouter.url) => {
  switch url.path {
  | list{_} => MapShapes->Some
  | list{_, "map"} => MapMaker->Some
  | list{"hex-grid", "about"} => About->Some
  | _ => None
  }
}

let toString = x =>
  switch x {
  | MapShapes => buildUrl("/")
  | MapMaker => buildUrl("/map")
  | About => buildUrl("/about")
  }

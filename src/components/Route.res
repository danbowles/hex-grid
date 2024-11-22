// TODO: Get this from vite config somehow?
let baseUrl = "/hex-grid"

let buildUrl = (path: string) => baseUrl ++ path

type t =
  | Home
  | MapMaker
  | About

let fromUrl = (url: RescriptReactRouter.url) => {
  switch url.path {
  | list{"hex-grid"} => Home->Some
  | list{"hex-grid", "map"} => MapMaker->Some
  | list{"hex-grid", "about"} => About->Some
  | _ => None
  }
}

let toString = x =>
  switch x {
  | Home => buildUrl("/")
  | MapMaker => buildUrl("/map")
  | About => buildUrl("/about")
  }

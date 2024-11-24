let useRouter = () => RescriptReactRouter.useUrl()->Route.fromUrl

let push = route => route->Route.toString->RescriptReactRouter.push

module Link = {
  @react.component
  let make = (~route: Route.t, ~children) => {
    let useRouter = () => RescriptReactRouter.useUrl()
    let location = route->Route.toString
    let currentRoute = useRouter()->Route.fromUrl
    let baseClassNames = "font-bold py-2 px-4 rounded inline-block"
    let className =
      currentRoute == Some(route)
        ? baseClassNames ++ " text-white bg-blue-900 hover:underline"
        : baseClassNames ++ " text-blue-900 hover:underline"
    <a
      className
      href=location
      onClick={event =>
        if (
          !(event->ReactEvent.Mouse.defaultPrevented) &&
          (event->ReactEvent.Mouse.button == 0 &&
          (!(event->ReactEvent.Mouse.altKey) &&
          (!(event->ReactEvent.Mouse.ctrlKey) &&
          (!(event->ReactEvent.Mouse.metaKey) && !(event->ReactEvent.Mouse.shiftKey)))))
        ) {
          event->ReactEvent.Mouse.preventDefault
          location->RescriptReactRouter.push
        }}>
      children
    </a>
  }
}

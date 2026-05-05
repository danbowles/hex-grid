module Header = {
  @react.component
  let make = () => {
    let menuRef = React.useRef(Nullable.Null)
    let (isMenuOpen, setIsMenuOpen) = React.useState(() => false)

    // TODO: Rework this a bit; The nav re-opens due to the mousedown event
    let toggleMenu = () => {
      setIsMenuOpen(prev => !prev)
    }
    // TODO: Cleanup these classes, maybe the whole component? 🫠
    let navClasses = "absolute right-4 top-20 bg-white border border-gray-500 rounded shadow-lg p-2"
    let navClasses = navClasses ++ " " ++ (isMenuOpen ? "flex" : "hidden")
    let navClasses =
      navClasses ++
      " " ++ "lg:flex lg:top-0 lg:right-0 lg:relative lg:items-right lg:shadow-none lg:mx-auto lg:border-none"

    let handleClickOutside = (event: Dom.event) => {
      switch menuRef.current->Nullable.toOption {
      | Some(menu) =>
        if (
          !Webapi.Dom.Element.contains(
            menu,
            ~child=event->Webapi.Dom.Event.target->Webapi.Dom.EventTarget.unsafeAsElement,
          )
        ) {
          setIsMenuOpen(_ => false)
        }
      | None => ()
      }
      ()
    }

    switch menuRef.current->Nullable.toOption {
    | Some(_) => Webapi.Dom.Document.addEventListener(document, "mousedown", handleClickOutside)
    | None => ()
    }

    <>
      <div className="flex justify-start items-center px-4 my-4 flex-row">
        <div>
          <h1 className="text-3xl font-bold lg:text-4xl">
            {"Hexagon Grid Creator"->React.string}
          </h1>
          <p className="text-lg text-gray-600"> {"Playing around with Hexagons"->React.string} </p>
        </div>
        <div className=navClasses ref={ReactDOM.Ref.domRef(menuRef)}>
          <ul className="flex flex-col ml-auto lg:ml-0 lg:flex-row lg:space-x-2">
            {Route.routes
            ->Array.map(((route, _, label)) =>
              <li key=label>
                <Router.Link route> {label->React.string} </Router.Link>
              </li>
            )
            ->React.array}
          </ul>
        </div>
        <button
          className="ml-auto bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded cursor-pointer block lg:hidden outline-none focus:outline-none"
          type_="button"
          onClick={_ => toggleMenu()}
        >
          {"Menu"->React.string}
        </button>
      </div>
      <hr className="border-t-2 border-gray-300" />
    </>
  }
}

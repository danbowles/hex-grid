module Header = {
  @react.component
  let make = () => {
    let menuRef = React.useRef(Nullable.Null)
    let (isMenuOpen, setIsMenuOpen) = React.useState(() => false)
    let (openGroup: option<Route.group>, setOpenGroup) = React.useState(() => None)

    // TODO: Rework this a bit; The nav re-opens due to the mousedown event
    let toggleMenu = () => {
      setIsMenuOpen(prev => !prev)
    }

    // TODO: Cleanup these classes, maybe the whole component? 🫠
    let navClasses =
      "absolute right-4 top-20 z-20 bg-white border border-gray-300 rounded shadow-lg p-3"
    let navClasses = navClasses ++ " " ++ (isMenuOpen ? "flex" : "hidden")
    let navClasses =
      navClasses ++
      " " ++ "lg:flex lg:top-auto lg:right-auto lg:relative lg:items-center lg:shadow-none lg:ml-auto lg:border-none lg:p-0"

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
          setOpenGroup(_ => None)
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
          <ul className="flex flex-col gap-3 ml-auto lg:hidden">
            {Route.groups
            ->Array.map(group => {
              let groupLabel = Route.groupToString(group)
              let experiments = Route.routesForGroup(group)

              <li key=groupLabel className="flex flex-col gap-1">
                <span
                  className="px-4 text-xs font-semibold uppercase tracking-wide text-gray-500 lg:px-0"
                >
                  {groupLabel->React.string}
                </span>
                <ul className="flex flex-col gap-1 lg:flex-row">
                  {experiments
                  ->Array.map(experiment =>
                    <li key=experiment.label>
                      <Router.Link route={experiment.route}>
                        <span> {experiment.label->React.string} </span>
                        <span
                          className="rounded border border-blue-200 bg-white px-1.5 py-0.5 text-[0.65rem] font-semibold uppercase text-blue-700"
                        >
                          {experiment.renderer->Route.rendererToString->React.string}
                        </span>
                      </Router.Link>
                    </li>
                  )
                  ->React.array}
                </ul>
              </li>
            })
            ->React.array}
          </ul>
          <ul className="hidden lg:flex lg:items-center lg:gap-1">
            {Route.groups
            ->Array.map(group => {
              let groupLabel = Route.groupToString(group)
              let experiments = Route.routesForGroup(group)
              let isOpen = openGroup == Some(group)
              let buttonClassName =
                isOpen
                  ? "inline-flex items-center gap-1 rounded px-3 py-2 text-sm font-bold text-white bg-blue-900"
                  : "inline-flex items-center gap-1 rounded px-3 py-2 text-sm font-bold text-blue-900 hover:bg-blue-50"
              let iconClassName =
                isOpen ? "h-4 w-4 transition-transform rotate-180" : "h-4 w-4 transition-transform"

              <li
                key=groupLabel
                className="relative"
                onMouseEnter={_ => setOpenGroup(_ => Some(group))}
                onMouseLeave={_ => setOpenGroup(_ => None)}
              >
                <button
                  type_="button"
                  className=buttonClassName
                  onClick={_ => setOpenGroup(_ => Some(group))}
                  onFocus={_ => setOpenGroup(_ => Some(group))}
                >
                  <span> {groupLabel->React.string} </span>
                  <HeroIcons.Outline.ChevronDownIcon className=iconClassName />
                </button>
                {isOpen
                  ? <div
                      className="absolute right-0 top-full z-30 w-56 pt-2"
                    >
                      <div className="rounded border border-gray-200 bg-white p-2 shadow-lg">
                        <ul className="flex flex-col gap-1">
                          {experiments
                          ->Array.map(experiment =>
                            <li key=experiment.label>
                              <Router.Link route={experiment.route}>
                                <span> {experiment.label->React.string} </span>
                                <span
                                  className="rounded border border-blue-200 bg-white px-1.5 py-0.5 text-[0.65rem] font-semibold uppercase text-blue-700"
                                >
                                  {experiment.renderer->Route.rendererToString->React.string}
                                </span>
                              </Router.Link>
                            </li>
                          )
                          ->React.array}
                        </ul>
                      </div>
                    </div>
                  : <> </>}
              </li>
            })
            ->React.array}
          </ul>
        </div>
        <button
          className="ml-auto inline-flex items-center gap-2 bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded cursor-pointer lg:hidden outline-none focus:outline-none"
          type_="button"
          onClick={_ => toggleMenu()}
        >
          {isMenuOpen
            ? <HeroIcons.Outline.XMarkIcon className="h-5 w-5" />
            : <HeroIcons.Outline.Bars3Icon className="h-5 w-5" />}
          <span> {"Menu"->React.string} </span>
        </button>
      </div>
      <hr className="border-t-2 border-gray-300" />
    </>
  }
}

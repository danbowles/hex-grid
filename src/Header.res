module Header = {
  @react.component
  let make = () => {
    let (isMenuOpen, setIsMenuOpen) = React.useState(() => false)
    let toggleMenu = () => setIsMenuOpen(prev => !prev)

    let navClasses = `lg:flex items-right m-6 ${isMenuOpen ? "flex" : "hidden"}`

    <>
      <div className="flex justify-start items-center px-4 my-4 md:mb-0 flex-row">
        <div>
          <h1 className="text-3xl font-bold lg:text-4xl">
            {"Hexagon Grid Creator"->React.string}
          </h1>
          <p className="text-lg text-gray-600"> {"Playing around with Hexagons"->React.string} </p>
        </div>
        <button
          className="ml-auto bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded cursor-pointer block lg:hidden outline-none focus:outline-none"
          type_="button"
          onClick={_ => toggleMenu()}>
          {"Menu"->React.string}
        </button>
      </div>
      <div className=navClasses>
        <ul className="flex flex-col ml-auto lg:ml-0 lg:flex-row lg:space-x-4">
          <li>
            <Router.Link route=Route.MapShapes> {"Map Shapes"->React.string} </Router.Link>
          </li>
          <li>
            <Router.Link route=Route.Pathfinding> {"Pathfinding"->React.string} </Router.Link>
          </li>
          <li>
            <Router.Link route=Route.MapMaker> {"Map Maker"->React.string} </Router.Link>
          </li>
          <li>
            <Router.Link route=Route.About> {"About"->React.string} </Router.Link>
          </li>
        </ul>
      </div>
      <hr className="border-t-2 border-gray-300" />
    </>
  }
}

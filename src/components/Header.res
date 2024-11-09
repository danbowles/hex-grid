module Header = {
  @react.component
  let make = () => <>
    <div className="flex justify-start items-center mb-8 flex-col md:flex-row">
      <div>
        <h1 className="text-4xl font-bold"> {"Hexagon Grid Creator"->React.string} </h1>
        <p className="text-lg text-gray-600">
          {"Create and visualize hexagonal grids with ease"->React.string}
        </p>
      </div>
      <div className="flex flex-wrap space-x-4 m-0 mt-4 md:ml-auto">
        <a
          href="https://www.redblobgames.com/grids/hexagons/"
          target="_blank"
          className="text-blue-500 hover:underline">
          {React.string("Reference")}
        </a>
        <a
          href="https://rescript-lang.org/"
          target="_blank"
          className="text-blue-500 hover:underline">
          {React.string("ReScript")}
        </a>
        <a href="https://reactjs.org/" target="_blank" className="text-blue-500 hover:underline">
          {React.string("React")}
        </a>
        <a href="#" target="_blank" className="text-blue-500 hover:underline">
          {React.string("GitHub Repo")}
        </a>
      </div>
    </div>
    <hr className="my-8 border-t-2 border-gray-300" />
  </>
}

module Footer = {
  @react.component
  let make = () =>
    <footer className="my-5">
      <hr className="mb-6 border-b-1 border-blueGray-600" />
      <div className="flex justify-center space-x-4">
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
        <a
          href="https://github.com/danbowles/hex-grid"
          target="_blank"
          className="text-blue-500 hover:underline">
          {React.string("GitHub Repo")}
        </a>
      </div>
    </footer>
}

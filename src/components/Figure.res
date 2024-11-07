module Figure = {
  @react.component
  let make = (~caption=?, ~children) => {
    <figure>
      {switch caption {
      | Some(caption) =>
        <figcaption className="text-2xl font-mono font-bold mb-3 text-gray-500">
          {caption->React.string}
        </figcaption>
      | None => <> </>
      }}
      <div className="border-4 border-indigo-200 rounded-lg mb-6"> {children} </div>
    </figure>
  }
}

module FigureWithControls = {
  @react.component
  let make = (~caption=?, ~children) => {
    let clonedChildren = React.cloneElement(children, {"newProp": "newValue"})
    Js.log(clonedChildren)
    <figure>
      {switch caption {
      | Some(caption) =>
        <figcaption className="text-2xl font-mono font-bold mb-3 text-gray-500">
          {caption->React.string}
        </figcaption>
      | None => <> </>
      }}
        <div className="flex justify-center space-x-4 mb-4">
          <label className="flex items-center space-x-2">
            <input type_="checkbox" className="form-checkbox h-5 w-5 text-blue-600" />
            <span className="text-gray-700"> {"Toggle 1"->React.string} </span>
          </label>
          <label className="flex items-center space-x-2">
            <input type_="checkbox" className="form-checkbox h-5 w-5 text-blue-600" />
            <span className="text-gray-700"> {"Toggle 2"->React.string} </span>
          </label>
          <label className="flex items-center space-x-2">
            <input type_="checkbox" className="form-checkbox h-5 w-5 text-blue-600" />
            <span className="text-gray-700"> {"Toggle 3"->React.string} </span>
          </label>
        </div>
      <div className="border-4 border-indigo-200 rounded-lg mb-6">
        {clonedChildren}
        // {children}
      </div>
    </figure>
  }
}

module Header = {
  @react.component
  let make = () => <>
    <div className="flex justify-start items-center mb-8 flex-col md:flex-row">
      <div>
        <h1 className="text-4xl font-bold mt-8"> {"Hexagon Grid Creator"->React.string} </h1>
        <p className="text-lg text-gray-600"> {"Playing around with Hexagons"->React.string} </p>
      </div>
    </div>
    <hr className="border-t-2 border-gray-300" />
  </>
}

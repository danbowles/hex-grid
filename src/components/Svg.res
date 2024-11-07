type svgRect = {
  x: float,
  y: float,
  width: float,
  height: float,
}
@send external getBBox: (Dom.element) => svgRect = "getBBox"

module Svg = {
  module Group = {
  @react.component
  let make = (~children, ~setGroupRef=?) => {
    let setGroupRef = element => {
    switch setGroupRef {
    | Some(setGroupRef) => setGroupRef(element)
    | None => ()
    }
  }
    <g ref={ReactDOM.Ref.callbackDomRef(setGroupRef)}>
      {children}
    </g>
  }
}
  @react.component
  let make = (~children) => {
    let innerPadding = 2.0
    let (viewBox, setViewBox) = React.useState(() => "-80 -60 200 200")
  let handleGroupRef = el => {
    switch el->Nullable.toOption {
    | Some(el) => {
      let {x, y, width, height} = el->getBBox
      // Oof.  Likely a better way to do this.
      setViewBox(_ => `${(x-.innerPadding)->Float.toString} ${(y-.innerPadding)->Float.toString} ${(width+.(innerPadding*.2.0))->Float.toString}  ${(height+.(innerPadding*.2.0))->Float.toString}`)
    }
    | None => ()
    }
  }
    <svg viewBox>
      <Group setGroupRef={handleGroupRef}>
      {children}
      </Group>
    </svg>
  }
}

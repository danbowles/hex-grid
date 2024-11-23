type svgRect = {
  x: float,
  y: float,
  width: float,
  height: float,
}
@send external getBBox: Dom.element => svgRect = "getBBox"

module Svg = {
  module DrawingContext = {
    let context = React.createContext(false)

    let useContext = () => React.useContext(context)

    module Provider = {
      let provider = React.Context.provider(context)
      @react.component
      let make = (~value, ~children) => {
        React.createElement(provider, {value, children})
      }
    }
  }
  module Group = {
    @react.component
    let make = (~children, ~setGroupRef=?) => {
      let (canDraw, setCanDraw) = React.useState(_ => false)
      let (drawing, setDrawing) = React.useState(_ => false)
      let setGroupRef = element => {
        switch setGroupRef {
        | Some(setGroupRef) => setGroupRef(element)
        | None => ()
        }
      }
      // Set CanDraw
      let handleMouseEnter = _ => setCanDraw(_ => true)
      let handleMouseLeave = _ => {
        setCanDraw(_ => false)
        setDrawing(_ => false)
      }

      let handleMouseDown = e => {
        e->ReactEvent.Mouse.preventDefault
        setDrawing(_ => canDraw && true)
      }
      let handleMouseUp = _ => setDrawing(_ => false)
      let handleMouseMove = e => {
        e->ReactEvent.Mouse.preventDefault
      }

      <DrawingContext.Provider value=drawing>
        <g
          onMouseEnter={handleMouseEnter}
          onMouseLeave={handleMouseLeave}
          onMouseDown={handleMouseDown}
          onMouseUp={handleMouseUp}
          onMouseMove={handleMouseMove}
          ref={ReactDOM.Ref.callbackDomRef(setGroupRef)}>
          {children}
        </g>
      </DrawingContext.Provider>
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
          setViewBox(_ =>
            `${(x -. innerPadding)->Float.toString} ${(y -. innerPadding)
                ->Float.toString} ${(width +. innerPadding *. 2.0)->Float.toString}  ${(height +.
              innerPadding *. 2.0)->Float.toString}`
          )
        }
      | None => ()
      }
    }
    <svg viewBox>
      <Group setGroupRef={handleGroupRef}> {children} </Group>
    </svg>
  }
}

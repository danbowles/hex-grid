open Contexts

type svgMatrix = {
  a: float,
  b: float,
  c: float,
  d: float,
  e: float,
  f: float,
}
type svgRect = {
  x: float,
  y: float,
  width: float,
  height: float,
}

type domPoint = {
  x: float,
  y: float,
}

@new external createDomPoint: (float, float) => domPoint = "DOMPoint"

@send external getBBox: Dom.element => svgRect = "getBBox"
@send external getScreenCTM: Dom.element => svgMatrix = "getScreenCTM"
@send external inverse: svgMatrix => svgMatrix = "inverse"
@send external matrixTransform: (domPoint, svgMatrix) => domPoint = "matrixTransform"

module ScreenCtmContext = {
  let emptySvgMatrix = {a: 0.0, b: 0.0, c: 0.0, d: 0.0, e: 0.0, f: 0.0}
  let context = React.createContext((emptySvgMatrix, None))
  let useContext = () => React.useContext(context)
  module Provider = {
    let provider = React.Context.provider(context)
    @react.component
    let make = (~value, ~children) => {
      React.createElement(provider, {value, children})
    }
  }
}

module Svg = {
  module Group = {
    @react.component
    let make = (~children, ~setGroupRef=?) => {
      let (canDrag, setCanDrag) = React.useState(_ => false)
      let (dragging, setDragging) = React.useState(_ => false)
      // Js.log(("canDrag", canDrag, "dragging", dragging))

      let setGroupRef = element => {
        switch setGroupRef {
        | Some(setGroupRef) => setGroupRef(element)
        | None => ()
        }
      }
      // Set Dragging
      let handleMouseEnter = _ => setCanDrag(_ => true)
      let handleMouseLeave = _ => {
        setCanDrag(_ => false)
        setDragging(_ => false)
      }

      let handleMouseDown = e => {
        e->ReactEvent.Mouse.preventDefault
        setDragging(_ => canDrag && true)
      }
      let handleMouseUp = _ => setDragging(_ => false)
      let handleMouseMove = e => {
        e->ReactEvent.Mouse.preventDefault
      }

      Js.log("Render Group")

      <DraggingContext.Provider value=dragging>
        <g
          onMouseEnter={handleMouseEnter}
          onMouseLeave={handleMouseLeave}
          onMouseDown={handleMouseDown}
          onMouseUp={handleMouseUp}
          onMouseMove={handleMouseMove}
          ref={ReactDOM.Ref.callbackDomRef(setGroupRef)}>
          {children}
        </g>
      </DraggingContext.Provider>
    }
  }
  @react.component
  let make = (~children) => {
    let (viewBox, setViewBox) = React.useState(() => "-80 -60 200 200")
    let innerPadding = 2.0
    let (svgMatrix, setSvgMatrix) = React.useState(() => {
      {a: 1.0, b: 0.0, c: 0.0, d: 1.0, e: 0.0, f: 0.0}
    })
    let svgRef = React.useRef(Nullable.null)

    React.useEffect(() => {
      switch svgRef.current->Nullable.toOption {
      | Some(svgEl) => {
          let screenCtm = getScreenCTM(svgEl)
          setSvgMatrix(_ => screenCtm->inverse)
        }
      | None => ()
      }
      None
    }, (viewBox, svgRef))

    let handleGroupRef = groupEl => {
      switch groupEl->Nullable.toOption {
      | Some(groupEl) => {
          let {x, y, width, height} = groupEl->getBBox
          let viewBox: array<float> = [
            x -. innerPadding,
            y -. innerPadding,
            width +. innerPadding *. 2.0,
            height +. innerPadding *. 2.0,
          ]
          setViewBox(_ => viewBox->Array.map(f => f->Float.toString)->Array.join(" "))
        }
      | None => ()
      }
    }
    Js.log("Render Svg")
    <ScreenCtmContext.Provider value={(svgMatrix, svgRef.current->Nullable.toOption)}>
      <svg viewBox ref={ReactDOM.Ref.domRef(svgRef)}>
        <Group setGroupRef={handleGroupRef}> {children} </Group>
      </svg>
    </ScreenCtmContext.Provider>
  }
}

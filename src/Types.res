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

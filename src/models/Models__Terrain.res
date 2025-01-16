type kind = Grass | Water | Sand | Mountain | Clear
type t = {kind: kind, fillColor: string, bgColor: string, textColor: string}

let getTextColor = kind =>
  switch kind {
  | Grass => "text-white"
  | Water => "text-white"
  | Sand => "text-black"
  | Mountain => "text-white"
  | Clear => "text-black"
  }
let getFillColor = kind =>
  switch kind {
  | Grass => "fill-green-500"
  | Water => "fill-blue-500"
  | Sand => "fill-yellow-500"
  | Mountain => "fill-gray-500"
  | Clear => "fill-slate-50"
  }
let getBgColor = kind =>
  switch kind {
  | Grass => "bg-green-500"
  | Water => "bg-blue-500"
  | Sand => "bg-yellow-500"
  | Mountain => "bg-gray-500"
  | Clear => "bg-slate-50"
  }

let kindToString = kind =>
  switch kind {
  | Grass => "Grass"
  | Water => "Water"
  | Sand => "Sand"
  | Mountain => "Mountain"
  | Clear => "Clear"
  }

let make = kind => {
  kind,
  fillColor: getFillColor(kind),
  textColor: getTextColor(kind),
  bgColor: getBgColor(kind),
}

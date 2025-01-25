type t<'a> = {
  front: list<'a>,
  back: list<'a>,
}

let makeEmpty = (): t<'a> => {
  front: list{},
  back: list{},
}

let isEmpty = ({front, back}: t<'a>): bool => {
  switch (front, back) {
  | (list{}, list{}) => true
  | _ => false
  }
}

let put = (queue: t<'a>, item: 'a): t<'a> => {
  {
    ...queue,
    back: list{item, ...queue.back},
  }
}

let normalize = (queue: t<'a>): t<'a> =>
  switch queue.front {
  | list{} => {
      front: List.reverse(queue.back),
      back: list{},
    }
  | _ => queue
  }

let get = (queue: t<'a>): option<(t<'a>, 'a)> => {
  let queue = normalize(queue)
  switch queue.front {
  | list{} => None
  | list{hd, ...tail} => Some({front: tail, back: queue.back}, hd)
  }
}

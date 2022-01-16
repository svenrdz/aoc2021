import ./utils
import std/[strutils, sequtils]

type
  Position = enum
    Left Right
  Element = object
    value: int
    depth: int
    pos: Position

  Number = seq[Element]
  ReductionKind = enum
    None Explosion Split
  Reduction = object
    kind: ReductionKind
    idx: int

  PairKind = enum
    pkPair pkValue
  Pair = ref object
    case kind: PairKind
    of pkPair:
      x, y: Pair
    of pkValue:
      value: int

proc `$`(pair: Pair): string =
  case pair.kind
  of pkValue: $pair.value
  of pkPair: "[" & $pair.x & "," & $pair.y & "]"

proc toPair(num: Number, idx: var int, depth = 0): Pair =
  while idx < num.len:
    if num[idx].depth >= depth:
      let
        x = num.toPair(idx, depth + 1)
        y = num.toPair(idx, depth + 1)
      return Pair(kind: pkPair, x: x, y: y)
    else:
      inc idx
      return Pair(kind: pkValue, value: num[idx - 1].value)

proc toPair(num: Number): Pair =
  var i = 0
  num.toPair(i)

proc initElement(value, depth: int, pos: Position): Element =
  result.value = value
  result.depth = depth
  result.pos = pos

proc at(kind: ReductionKind, idx: int): Reduction =
  Reduction(kind: kind, idx: idx)

proc parse(file: string): seq[Number] =
  for line in read file:
    var
      pos: array[5, Position]
      depth = -1
      num: Number
    for ch in line:
      case ch
      of '[':
        depth += 1
        pos[depth] = Left
      of ']':
        depth -= 1
      of ',':
        pos[depth] = Right
      else:
        let
          value = parseInt $ch
          element = initElement(value, depth, pos[depth])
        num.add element
    result.add num

proc reduction(num: Number): Reduction =
  for i, element in num:
    if element.depth > 3:
      return Explosion.at(i)
  for i, element in num:
    if element.value > 9:
      return Split.at(i)
  None.at(0)

proc reduceImpl(num: var Number): bool =
  let reduc = num.reduction
  case reduc.kind
  of Explosion:
    let
      lIdx = reduc.idx
      rIdx = reduc.idx + 1
      lValue = num[lIdx].value
      rValue = num[rIdx].value
      someAtLeft = lIdx > 0
      someAtRight = rIdx < num.len - 1
    num[lIdx].value = 0
    dec num[lIdx].depth
    num.delete rIdx
    if someAtLeft:
      num[lIdx - 1].value += lValue
    if someAtRight:
      num[rIdx].value += rValue
    true
  of Split:
    let
      lValue = num[reduc.idx].value div 2
      rValue = num[reduc.idx].value - lValue
      depth = num[reduc.idx].depth + 1
    num[reduc.idx] = initElement(lValue, depth, Left)
    num.insert(initElement(rValue, depth, Right), reduc.idx + 1)
    true
  else:
    false

proc reduce(num: var Number) =
  while reduceImpl num:
    discard

proc `+`(a, b: Number): Number =
  result = a & b
  for i in 0 ..< result.len:
    inc result[i].depth
  reduce result

proc sum(pair: Pair): int =
  if pair.kind == pkValue:
    return pair.value
  else:
    3 * pair.x.sum + 2 * pair.y.sum

proc sum(num: Number): int =
  num.toPair.sum

proc anyTwoSums(nums: seq[Number]): seq[int] =
  for i, num0 in nums:
    for j, num1 in nums:
      if i == j:
        continue
      result.add sum(num0 + num1)

day 18:
  let numbers = parse file
  part1 = numbers.foldl(a + b).sum
  part2 = numbers.anyTwoSums.max

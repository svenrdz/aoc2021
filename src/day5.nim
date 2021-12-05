import utils, sets, strutils, sequtils, algorithm

type
  Point = object
    x, y: int
  Vent = object
    a, b: Point

proc pt(x, y: int): Point =
  Point(x: x, y: y)

proc `==`(a, b: Point): bool =
  a.x == b.x and a.y == b.y

proc parse(line: string): Vent =
  let
    ab = line.split(" -> ")
    aStr = ab[0].split(',')
    bStr = ab[1].split(',')
  result.a = pt(parseInt(aStr[0]), parseInt(aStr[1]))
  result.b = pt(parseInt(bStr[0]), parseInt(bStr[1]))

iterator items(v: Vent, diagonals: bool = false): Point =
  var xs, ys: seq[int]
  let
    lowX = min(v.a.x, v.b.x)
    highX = max(v.a.x, v.b.x)
    lowY = min(v.a.y, v.b.y)
    highY = max(v.a.y, v.b.y)
  if lowY == highY:
    xs = toSeq(lowX .. highX)
    ys = repeat(v.a.y, xs.len)
  elif lowX == highX:
    ys = toSeq(lowY .. highY)
    xs = repeat(v.a.x, ys.len)
  elif diagonals:
    xs = toSeq(lowX .. highX)
    ys = toSeq(lowY .. highY)
    if v.a == pt(lowX, highY) or v.a == pt(highX, lowY):
      xs = xs.reversed
  for (x, y) in zip(xs, ys):
    yield pt(x, y)

proc duplicates(lines: seq[string], diagonals: bool = false): HashSet[Point] =
  var
    seen: HashSet[Point]
    vent: Vent
  for line in lines:
    vent = parse line
    for p in vent.items(diagonals):
      if p in seen:
        result.incl p
      seen.incl p

day 5:
  let
    lines = read file
  part1 = lines.duplicates.len
  part2 = lines.duplicates(true).len

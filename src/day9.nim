import ./utils
import std/[strutils, sequtils, tables, terminal]
import std/[algorithm, sugar]

type
  Position = tuple[x, y: int]
  Direction = enum
    LocalMin
    Unknown
    Up
    Down
    Right
    Left
  Grid = object
    data: seq[seq[int]]
    width, height: int
  Slope = object
    start, nd: Position
    kind: Direction
  Basin = seq[Position]
  Basins = Table[Position, Basin]

  Sortable = tuple[pos: Position, basin: Basin]

proc `[]`(g: Grid, pos: Position): int =
  g.data[pos.y][pos.x]

proc `[]=`(g: var Grid, x, y: int, item: int) =
  g.data[y][x] = item

iterator positions(g: Grid): Position =
  for y in 0 ..< g.height:
    for x in 0 ..< g.width:
      yield (x, y)

proc contains(basins: Basins, pos: Position): bool =
  for basin in basins.values:
    for basinPos in basin:
      if pos == basinPos:
        return true
  false

proc print(g: Grid, basins: Basins) =
  var pos: Position
  for y in 0 ..< g.height:
    for x in 0 ..< g.width:
      pos = (x, y)
      if basins.hasKey(pos):
        stdout.setForegroundColor fgRed
      elif pos in basins:
        stdout.setForegroundColor fgGreen
      else:
        stdout.setForegroundColor fgWhite
      stdout.write $g[pos]
    stdout.write("\n")
  stdout.setForegroundColor(fgWhite)

proc parse(filename: string): Grid =
  for y, line in read(filename):
    result.data.add newSeq[int](line.len)
    for x, char in line:
      result[x, y] = parseInt($char)
  result.width = result.data[0].len
  result.height = result.data.len

proc contains(g: Grid, pos: Position): bool =
  pos.x >= 0 and pos.x < g.width and pos.y >= 0 and pos.y < g.height

proc `+`(a, b: Position): Position =
  (a.x + b.x, a.y + b.y)

proc position(direction: Direction): Position =
  case direction
  of Up: (0, -1)
  of Down: (0, 1)
  of Left: (-1, 0)
  of Right: (1, 0)
  else: (0, 0)

proc initDownSlope(pos: Position, kind: Direction = Unknown): Slope =
  result.start = pos
  result.nd = pos
  result.kind = kind

proc flow(g: Grid, pos: Position): Slope =
  result = initDownSlope(pos, LocalMin)
  for kind in [Up, Down, Left, Right]:
    let nd = pos + kind.position
    if nd in g and g[nd] <= g[result.nd]:
      result.nd = nd
      result.kind = kind

proc localmins(g: Grid): seq[Position] =
  var slope: Slope
  for pos in g.positions:
    slope = g.flow(pos)
    if slope.kind == LocalMin:
      result.add pos

proc lowsum(g: Grid): int =
  for localmin in g.localmins:
    result.inc g[localmin] + 1

proc basins(g: Grid): Basins =
  for localmin in g.localmins:
    result[localmin] = @[]
  for pos in g.positions:
    if g[pos] == 9:
      continue
    var slope = initDownSlope(pos)
    while slope.kind != LocalMin:
      slope = g.flow(slope.nd)
    result[slope.nd].add pos

proc sorted(basins: Basins): seq[Sortable] =
  for pos, basin in basins:
    result.add (pos, basin)
  result.sort(
    (a, b: Sortable) => cmp(a.basin.len, b.basin.len),
    Descending)

proc basinsum(g: Grid): int =
  var largestBasins: seq[int]
  for (pos, basin) in g.basins.sorted[0..2]:
    largestBasins.add basin.len
  largestBasins.foldl a * b

day 9:
  let
    grid = parse file
  grid.print(grid.basins)
  part1 = grid.lowsum
  part2 = grid.basinsum

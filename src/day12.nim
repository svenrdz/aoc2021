import ./utils
import std/[strutils, sequtils, sets, tables]

type
  Cave = string
  Edge = array[2, Cave]
  Path = seq[Cave]
  CaveSystem = object
    caves: HashSet[Cave]
    edges: seq[Edge]

proc parse(file: string): CaveSystem =
  let pairs = read(file).mapIt(it.split('-'))
  result.edges = pairs.mapIt([it[0], it[1]])
  result.caves = pairs.mapIt(it.toHashSet).foldl(a + b)

proc isBig(cave: Cave): bool =
  cave == toUpperAscii cave

proc isSmall(cave: Cave): bool =
  not cave.isBig

proc canVisit(path: Path, cave: Cave, maxVisits: int): bool =
  let visits = path.toCountTable()
  if cave.isBig or cave notin visits:
    return true
  elif cave == "start" or visits[cave] >= maxVisits:
    return false
  for cave, count in visits:
    if cave.isSmall and count > 1:
      return false
  true

proc neighbors(cs: CaveSystem, path: Path, maxVisits: int): seq[Cave] =
  let start = path[^1]
  var other: Cave
  for edge in cs.edges:
    if start notin edge:
      continue
    other = edge[1 - edge.find(start)]
    if path.canVisit(other, maxVisits):
      result.add other

proc paths(cs: CaveSystem, path: Path = @["start"], maxVisits = 1): seq[Path] =
  var newPath: Path
  for cave in cs.neighbors(path, maxVisits):
    newPath = path & @[cave]
    if cave == "end":
      result.add newPath
    else:
      result &= cs.paths(newPath, maxVisits)

day 12:
  let caveSystem = parse file
  part1 = caveSystem.paths(maxVisits = 1).len
  part2 = caveSystem.paths(maxVisits = 2).len

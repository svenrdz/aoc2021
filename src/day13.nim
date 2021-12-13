import ./utils
import std/[strutils, sequtils, sets]

type
  Axis = enum
    X = "x"
    Y = "y"
  Fold = object
    axis: Axis
    idx: int

  Dot = tuple[x, y: int]
  Paper = object
    dots: HashSet[Dot]
    width, height: int
    folds: seq[Fold]

proc `[]`(paper: Paper, x, y: int): bool =
  for dot in paper.dots:
    if dot == (x, y):
      return true
  false

proc `$`(paper: Paper): string =
  for y in 0 ..< paper.height:
    for x in 0 ..< paper.width:
      if paper[x, y]:
        result.add '#'
      else:
        result.add '.'
    result.add '\n'

proc parseFolds(lines: seq[string]): seq[Fold] =
  for line in lines:
    if not line.startswith("fold along"):
      continue
    let
      axis = parseEnum[Axis]($line[11])
      idx = parseInt(line.split('=')[1])
    result.add Fold(axis: axis, idx: idx)

proc parseDots(lines: seq[string]): HashSet[Dot] =
  for line in lines:
    if line.len == 0:
      break
    let pair = line.split(',')
    result.incl (parseInt(pair[0]), parseInt(pair[1]))

proc parse(lines: seq[string]): Paper =
  result.dots = parseDots lines
  result.folds = parseFolds lines
  result.width = result.dots.mapIt(it.x).max
  result.height = result.dots.mapIt(it.y).max

proc foldOnce(paper: Paper): Paper =
  let fold = paper.folds[0]
  result.folds = paper.folds[1..^1]
  for dot in paper.dots:
    case fold.axis
    of X:
      result.width = paper.width div 2
      result.height = paper.height
      if dot.x == fold.idx:
        continue
      elif dot.x > fold.idx:
        let newDot: Dot = (2 * fold.idx - dot.x, dot.y)
        if newDot.x < 0:
          continue
        result.dots.incl newDot
      else:
        result.dots.incl dot
    of Y:
      result.width = paper.width
      result.height = paper.height div 2
      if dot.y == fold.idx:
        continue
      elif dot.y > fold.idx:
        let newDot: Dot = (dot.x, 2 * fold.idx - dot.y)
        if newDot.y < 0:
          continue
        result.dots.incl newDot
      else:
        result.dots.incl dot

proc foldAll(paper: Paper): Paper =
  result = paper
  while result.folds.len > 0:
    result = foldOnce result

day 13:
  let
    lines = read file
    paper = parse lines
  part1 = paper.foldOnce.dots.len
  echo paper.foldAll

#..#..##...##....##.###..####.#..#..##..
#..#.#..#.#..#....#.#..#.#....#..#.#..#.
####.#....#..#....#.###..###..####.#....
#..#.#.##.####....#.#..#.#....#..#.#....
#..#.#..#.#..#.#..#.#..#.#....#..#.#..#.
#..#..###.#..#..##..###..####.#..#..##..

import ./utils
import std/[sequtils, sets]
import vmath

type
  Point = GVec2[int]
  Algo = seq[bool]
  Image = HashSet[Point]
  Corners = tuple[topleft, bottomright: Point]

proc parse(file: string): (Algo, Image) =
  let lines = read file
  for ch in lines[0]:
    result[0].add case ch
    of '#': true
    else: false
  for y, line in lines[2..^1]:
    for x, ch in line:
      if ch == '#':
        result[1].incl gvec2(x, y)

proc contains(c: Corners, p: Point): bool =
  if p.x < c.topleft.x: return false
  if p.y < c.topleft.y: return false
  if p.x > c.bottomright.x: return false
  if p.y > c.bottomright.y: return false
  true

proc corners(img: Image): Corners =
  let
    xs = img.mapIt(it[0])
    ys = img.mapIt(it[1])
  result.topleft = gvec2(xs.min, ys.min)
  result.bottomright = gvec2(xs.max, ys.max)

proc enhanceOnce(img: Image, alg: Algo, stepIdx: int): Image =
  let
    c = img.corners
    infbit = alg[0] and stepIdx mod 2 == 1
  for y in c.topleft.y - 1 .. c.bottomright.y + 1:
    for x in c.topleft.x - 1 .. c.bottomright.y + 1:
      let p = gvec2(x, y)
      var index = 0
      for dy in y-1 .. y+1:
        for dx in x-1 .. x+1:
          let dp = gvec2(dx, dy)
          index = index shl 1
          if (dp in c and dp in img) or (dp notin c and infbit):
            inc index
      if alg[index]:
        result.incl p

proc enhance(img: Image, alg: Algo, n: int): Image =
  result = img
  for i in 0 ..< n:
    result = result.enhanceOnce(alg, i)

day Ex:
  let
    (alg, img) = parse file
  part1 = img.enhance(alg, 2).len
  part2 = img.enhance(alg, 50).len

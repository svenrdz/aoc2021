import ./utils
import std/[strutils, sequtils, sets, options]
import vmath

type
  Point = GVec3[int]
  Scanner = seq[Point]
  Fingerprint = object
    scanner: Scanner
    sets: seq[Hashset[int]]
    all: Hashset[int]
  Resp = tuple[delta: Point, fp: Fingerprint]

proc pvec(x, y, z: int): Point =
  gvec3[int](x, y, z)

proc view(p: Point, i, m: array[3, int]): Point =
  pvec(
    m[0] * p[i[0]],
    m[1] * p[i[1]],
    m[2] * p[i[2]])

proc `{}`(p: Point, i: range[0..5], j: range[0..3]): Point =
  result = p
  result = case i
  of 0: result.view([0, 1, 2], [1, 1, 1])
  of 1: result.view([1, 0, 2], [1, -1, 1])
  of 2: result.view([0, 1, 2], [-1, -1, 1])
  of 3: result.view([1, 0, 2], [-1, 1, 1])
  of 4: result.view([2, 1, 0], [-1, 1, 1])
  of 5: result.view([2, 1, 0], [1, 1, -1])
  result = case j
  of 0: result.view([0, 1, 2], [1, 1, 1])
  of 1: result.view([0, 2, 1], [1, -1, 1])
  of 2: result.view([0, 1, 2], [1, -1, -1])
  of 3: result.view([0, 2, 1], [1, 1, -1])

proc `{}`(p: Point, k: range[0..23]): Point =
  p{k div 4, k mod 4}

proc `{}`(s: Scanner, i: range[0..5], j: range[0..3]): Scanner =
  for p in s:
    result.add p{i, j}

proc `{}`(s: Scanner, k: range[0..23]): Scanner =
  s{k div 4, k mod 4}

proc initFingerprint(s: Scanner): Fingerprint =
  result.scanner = s
  for p in s:
    let st = s.filterIt(it != p).mapIt((it - p).lengthSq).toHashSet
    result.sets.add st
    result.all.incl st

proc parsePoint(line: string): Point =
  let
    triplet = line.split(',')
    x = parseInt triplet[0]
    y = parseInt triplet[1]
    z = parseInt triplet[2]
  pvec(x, y, z)

proc parse(file: string): seq[Scanner] =
  var scanner: Scanner
  for line in read(file):
    if line.startsWith("---"):
      continue
    elif line.len == 0:
      result.add scanner
      scanner = @[]
    else:
      scanner.add parsePoint(line)
  if scanner.len > 0:
    result.add scanner

proc overlap(a, b: Fingerprint): Option[Resp] =
  if (a.all * b.all).len < 12:
    return none Resp
  let set0 = a.scanner.toHashSet
  for (p0, fp0) in zip(a.scanner, a.sets):
    for (p1, fp1) in zip(b.scanner, b.sets):
      if (fp0 * fp1).len >= 11:
        for k in 0..23:
          let
            delta = p0 - p1{k}
            scanner = b.scanner{k}.mapIt(it + delta)
            set1 = scanner.toHashSet
          if (set0 * set1).len >= 12:
            return some (delta, initFingerprint(scanner))

proc makeMap(fps: seq[Fingerprint]): (Scanner, Scanner) =
  var
    matched = fps[0..0]
    unmatched = fps[1..^1]
    nextUnmatched: seq[Fingerprint]
    all = fps[0].scanner.toHashSet()
    deltas: Scanner
    resp: Option[Resp]
    i = 0
  while unmatched.len > 0:
    let fp0 = matched[i]
    nextUnmatched = @[]
    for fp1 in unmatched:
      resp = overlap(fp0, fp1)
      if resp.isSome:
        matched.add resp.get.fp
        deltas.add resp.get.delta
        all.incl resp.get.fp.scanner.toHashSet
      else:
        nextUnmatched.add fp1
    unmatched = nextUnmatched
    inc i
  (all.toSeq, deltas)

proc manhattan(p: Point): int =
  let a = p.abs
  a[0] + a[1] + a[2]

proc largest(deltas: Scanner): int =
  var s: seq[int]
  for i, d0 in deltas:
    for d1 in deltas[i+1..^1]:
      s.add (d1 - d0).manhattan
  s.max

day 19:
  let
    scanners = parse file
    fingerprints = scanners.map initFingerprint
    (map, deltas) = makeMap fingerprints
  part1 = map.len
  part2 = deltas.largest

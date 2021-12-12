import ./utils
import std/[strutils, math, options]

import arraymancer

type
  Grid = object
    data: Tensor[int]
    flashes: seq[int]
    idx: int
    syncIdx: Option[int]

proc parse(file: string): Grid =
  result.data = zeros[int](10, 10)
  for i, line in read file:
    for j, char in line:
      result.data[i, j] = parseInt($char)

let
  weight = ones[int](1, 1, 3, 3)
  bias = zeros[int](1, 1, 1)
  padding = (1, 1)

proc squeeze2(t: Tensor[int]): Tensor[int] =
  t.squeeze(0).squeeze(0)

proc unsqueeze2(t: Tensor[int]): Tensor[int] =
  t.unsqueeze(0).unsqueeze(0)

proc any(t: Tensor[bool]): bool =
  t.astype(int).sum > 0

proc all(t: Tensor[bool]): bool =
  t.astype(int).sum == t.size

proc flashing(g: Grid): Tensor[bool] =
  g.data >. 9

proc asconv(t: Tensor[bool]): Tensor[int] =
  conv2d(t.astype(int).unsqueeze2(),
         weight, bias, padding).squeeze2()

proc step(g: var Grid) =
  inc g.idx
  g.data +.= 1
  var
    flashed = zeros[int](g.data.shape).astype(bool)
    flashing = g.flashing
  while any(flashed xor flashing):
    g.data += (flashed xor flashing).asconv
    flashed = flashed or flashing
    flashing = g.flashing
  flashing = g.flashing
  g.data[flashing] = 0
  g.flashes.add flashing.astype(int).sum()
  if all flashing:
    g.syncIdx = some g.idx

proc step(g: var Grid, nb: int, debug = false) =
  for i in 0 ..< nb:
    step g
    if debug:
      echo i+1
      echo g

proc stepUntilSync(g: var Grid) =
  while g.syncIdx.isNone:
    step g

day 11:
  var grid = parse file
  grid.step 100
  part1 = grid.flashes.sum
  stepUntilSync grid
  part2 = grid.syncIdx.get

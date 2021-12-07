import ./utils
import std/sequtils
import kashae
import arraymancer

type
  ConsumptionGrowth = enum
    ckConstant
    ckLinear

proc cumsum(n: int): int {.cache.} =
  for i in 0..n:
    result += i

proc lowestFuel(positions: seq[int], consumptionGrowth: ConsumptionGrowth): int =
  let
    positions = positions.toTensor.unsqueeze(0)
    moves = toSeq(positions.min .. positions.max)
    movesMat = moves.toTensor().unsqueeze(1)
    distances = (positions -. movesMat).abs()
  let spending = case consumptionGrowth
    of ckConstant:
      distances
    of ckLinear:
      distances.map_inline(cumsum(x))
  spending.sum(1).min()

day 7:
  let positions = readIntSeqCommaSep(file)
  part1 = lowestFuel(positions, ckConstant)
  part2 = lowestFuel(positions, ckLinear)

import utils, sequtils

proc sum(arr: openArray[int]): int =
  for val in arr:
    result += val

proc isPositive(x: int): int =
  x > 0 ? 1: 0

proc grad(input: openArray[int], windowLen: int): seq[int] =
  var window, prev: seq[int]
  prev = input[0 ..< windowLen]
  for idx in 0 .. input.len - windowLen:
    window = input[idx ..< idx + windowLen]
    result.add sum(window) - sum(prev)
    prev = window

proc compute(input: seq[int]): int =
  sum(toSeq(map(input, isPositive)))

day 1:
  let depths = readIntSeq(file)
  part1 = compute(grad(depths, 1))
  part2 = compute(grad(depths, 3))

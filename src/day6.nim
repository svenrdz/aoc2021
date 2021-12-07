import ./utils
import std/[strutils, sequtils, tables]

type
  Fishes = Table[int, int]

proc newFishes(timers: seq[int]): Fishes =
  for i in 0..8:
    result[i] = 0
  for t in timers:
    inc result[t]

proc step(fishes: Fishes): Fishes =
  result = newFishes(@[])
  for timer, nbFish in fishes:
    if timer > 0:
      result[timer - 1].inc nbFish
    else:
      result[6].inc nbFish
      result[8].inc nbFish

proc step(fishes: Fishes, n: int): Fishes =
  result = fishes
  for i in 1 .. n:
    result = result.step()

proc sum(fishes: Fishes): int =
  for nb in fishes.values:
    result.inc nb

day 6:
  let
    timers = map(read(file)[0].split(','), parseInt)
    fishes = newFishes(timers)
  part1 = fishes.step(80).sum
  part2 = fishes.step(256).sum

import ./utils
import std/[strutils, sequtils, tables, math]

type
  Pair = array[2, char]
  Rules = Table[Pair, char]
  Polymer = object
    # sequence: seq[Pair]
    rules: Rules
    atoms: CountTable[char]
    pairs: CountTable[Pair]

proc toPair(s: string): Pair =
  [s[0], s[1]]

proc insert(pair: Pair, mid: char): array[2, Pair] =
  [[pair[0], mid], [mid, pair[1]]]

proc getRulesFrom(lines: seq[string]): Rules =
  for line in lines:
    if "->" notin line: continue
    let
      rule = line.split(" -> ")
      pair = rule[0].toPair
      ch = rule[1][0]
    result[pair] = ch

proc parse(file: string): Polymer =
  let
    lines = read file
    polyStr = lines[0]
  result.rules = getRulesFrom lines
  result.atoms.inc polyStr[0]
  for i in 1 ..< polyStr.len:
    result.atoms.inc polyStr[i]
    result.pairs.inc polyStr[i-1..i].toPair

proc stepOnce(polymer: var Polymer) =
  let pairs = toSeq(polymer.pairs.pairs)
  for (pair, count) in pairs:
    let ch = polymer.rules[pair]
    polymer.atoms.inc(ch, count)
    polymer.pairs.inc(pair.insert(ch)[0], count)
    polymer.pairs.inc(pair.insert(ch)[1], count)
    polymer.pairs.inc(pair, -count) # decrease

proc step(polymer: Polymer, n = 1): Polymer =
  result = polymer
  for _ in 0 ..< n:
    stepOnce result

proc minMaxDiff(polymer: Polymer): int =
  polymer.atoms.largest[1] - polymer.atoms.smallest[1]

day 14:
  var polymer = parse file
  part1 = minMaxDiff polymer.step(10)
  part2 = minMaxDiff polymer.step(40)

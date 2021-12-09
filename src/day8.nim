import ./utils
import std/[tables, strutils, sequtils, math]

type
  Segment = enum
    A = "a"
    B = "b"
    C = "c"
    D = "d"
    E = "e"
    F = "f"
    G = "g"

  Digit = set[Segment]

  Patterns = array[10, Digit]
  Output = array[4, Digit]
  IdxMap = array[10, int]

  Display = object
    patterns: Patterns
    output: Output

  Solver = object
    display: Display
    idxMap: IdxMap

const uniqueLenDigits = {2: 1, 3: 7, 4: 4, 7: 8}.toTable()

proc makeSolver(display: Display): Solver =
  result.display = display

proc parseDigit(pattern: string): Digit =
  for char in pattern:
    result.incl parseEnum[Segment]($char)

proc parseDisplay(line: string): Display =
  let
    splitted = line.split(" | ")
    patterns = splitted[0].split(' ')
    output = splitted[1].split(' ')
  for i in 0 ..< patterns.len:
    result.patterns[i] = parseDigit(patterns[i])
  for i in 0 ..< output.len:
    result.output[i] = parseDigit(output[i])

proc countUniqueLenDigits(displays: seq[Display]): int =
  for display in displays:
    for digit in display.output:
      if digit.len in uniqueLenDigits:
        result.inc

proc `[]`(solver: Solver, i: int): Digit =
  solver.display.patterns[solver.idxMap[i]]

proc outputValue(solver: Solver): int =
  for outputIdx, output in solver.display.output:
    for i in 0..9:
      if output == solver[i]:
        result += 10 ^ (3 - outputIdx) * i
        break

proc solve(display: Display): int =
  var solver = display.makeSolver()
  block getAllUnique:
    for i, pattern in display.patterns:
      if pattern.len in uniqueLenDigits:
        solver.idxMap[uniqueLenDigits[pattern.len]] = i
  block findRemaining:
    let
      one = solver[1]
      four = solver[4]
      bd = four - one
    for i, pattern in display.patterns:
      case pattern.len:
      of 5:
        if one < pattern:
          solver.idxMap[3] = i
        elif bd < pattern:
          solver.idxMap[5] = i
        else:
          solver.idxMap[2] = i
      of 6:
        if four < pattern:
          solver.idxMap[9] = i
        elif bd < pattern:
          solver.idxMap[6] = i
        else:
          solver.idxMap[0] = i
      else:
        discard
  solver.outputValue

proc solve(displays: seq[Display]): seq[int] =
  for display in displays:
    result.add display.solve()

day 8:
  let
    lines = read(file)
    displays = map(lines, parseDisplay)
    solved = displays.solve()
  part1 = displays.countUniqueLenDigits()
  part2 = solved.sum()

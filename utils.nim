import os
import macros
import intsets
import strutils
import sequtils

proc read*(filename: string): seq[string] =
  toSeq(filename.lines)

proc readIntSeq*(filename: string): seq[int] =
  filename.read.map(parseInt)

proc readIntSet*(filename: string): IntSet =
  toIntSet(filename.readIntSeq)

proc toSet*(str: string): set[char] =
  for ch in str:
    result.incl ch

type Path = distinct string

template day*(path: Path, body: untyped, id: int = -1) =
  proc solve(file: string): array[1 .. 2, int] =
    let file {.inject.} = file
    var
      part1 {.inject.} = result[1]
      part2 {.inject.} = result[2]
    body
    [part1, part2]

  let sol = solve(path.string)
  let dayStr =
    case id
    of -1:
      "Example"
    else:
      "Day " & $id
  echo dayStr & " solutions:"
  echo "\tPart 1: " & $sol[1]
  echo "\tPart 2: " & $sol[2]

template day*(id: string, body: untyped) =
  day Path(id):
    body

template day*(id: int, body: untyped) =
  day Path("inputs" / $id):
    body
  do:
    id

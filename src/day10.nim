import ./utils
import std/algorithm

type
  Delimiter = enum
    Undefined
    RoundOpen = '('
    RoundClose = ')'
    TriangleOpen = '<'
    TriangleClose = '>'
    SquareOpen = '['
    SquareClose = ']'
    CurlyOpen = '{'
    CurlyClose = '}'

  Chunk = object
    openIdx: int
    kind: Delimiter
    closed: bool

  ChunkLine = object
    chunks: seq[Chunk]
    illegals: seq[Delimiter]

const
  Openers = {RoundOpen, TriangleOpen, SquareOpen, CurlyOpen}

converter toDelimiter(ch: char): Delimiter =
  case ch
  of '(': RoundOpen
  of ')': RoundClose
  of '<': TriangleOpen
  of '>': TriangleClose
  of '[': SquareOpen
  of ']': SquareClose
  of '{': CurlyOpen
  of '}': CurlyClose
  else: Undefined

proc newChunk(ch: Delimiter, idx: int): Chunk =
  result.kind = case ch:
    of RoundOpen: RoundClose
    of TriangleOpen: TriangleClose
    of SquareOpen: SquareClose
    of CurlyOpen: CurlyClose
    else: Undefined
  result.openIdx = idx
  result.closed = false

proc last(line: ChunkLine): Chunk =
  for i in countdown(line.chunks.len-1, 0, 1):
    if not line.chunks[i].closed:
      return line.chunks[i]

proc closeLast(line: var ChunkLine) =
  for i in countdown(line.chunks.len-1, 0, 1):
    if not line.chunks[i].closed:
      line.chunks[i].closed = true
      break

proc expected(line: ChunkLine): Delimiter =
  if line.chunks.len > 0:
    line.last.kind
  else:
    Undefined

proc expects(line: ChunkLine, delim: Delimiter): bool =
  delim == line.expected

proc isComplete(line: ChunkLine): bool =
  for chunk in line.chunks:
    if not chunk.closed:
      return false
  true

proc isCorrupted(line: ChunkLine): bool =
  line.illegals.len > 0

proc chunksFrom(line: string): ChunkLine =
  for i, delim in line:
    if delim in Openers:
      result.chunks.add delim.newChunk(i)
    elif result.expects delim:
      result.closeLast
    else:
      result.illegals.add delim
      break

proc parse(lines: seq[string]): seq[ChunkLine] =
  for line in lines:
    result.add chunksFrom line

proc corruptedScore(delim: Delimiter): int =
  case delim
  of RoundClose: 3
  of SquareClose: 57
  of CurlyClose: 1197
  of TriangleClose: 25137
  else: 0

proc corruptedScore(line: ChunkLine): int =
  for delim in line.illegals:
    result.inc delim.corruptedScore

proc corruptedScore(lines: seq[ChunkLine]): int =
  for line in lines:
    result.inc line.corruptedScore

proc incompleteScore(delim: Delimiter): int =
  case delim
  of RoundClose: 1
  of SquareClose: 2
  of CurlyClose: 3
  of TriangleClose: 4
  else: 0

proc incompleteScore(line: ChunkLine): int =
  var line = line
  while not line.isComplete:
    result = result * 5
    result.inc line.expected.incompleteScore
    line.closeLast

proc incompleteScore(lines: seq[ChunkLine]): int =
  var scores: seq[int]
  for line in lines:
    if line.isCorrupted: continue
    scores.add line.incompleteScore
  scores.sort
  scores[scores.len div 2]

day 10:
  let lines = parse read file
  part1 = lines.corruptedScore
  part2 = lines.incompleteScore

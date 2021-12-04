import utils, options, strutils, sequtils, arraymancer

type
  ITen = Tensor[int]
  Board = object
    numbers: ITen
    marks: ITen

proc initBoard(numbers: ITen = zeros[int](5, 5),
               marks: ITen = zeros[int](5, 5)): Board =
  result.numbers = numbers
  result.marks = marks

proc parseLine(line: string): seq[int] =
  for cur in countup(0, 12, 3):
    result.add parseInt(line[cur..cur+1].strip())

proc parseBoards(lines: seq[string]): seq[Board] =
  var
    board = initBoard()
    i = 0
  for line in lines[2..^1]:
    if line.len == 0:
      result.add board
      board = initBoard()
      i = 0
    else:
      board.numbers[i, _] = parseLine(line).toTensor().unsqueeze(0)
      inc i
  if i > 0:
    result.add board

proc iscomplete(board: Board): bool =
  let
    horizontal = (board.marks.sum(1) ==. 5)
    vertical = (board.marks.sum(0) ==. 5)
    hSum = horizontal.astype(int).sum()
    vSum = vertical.astype(int).sum()
  hSum + vSum > 0

proc unmarkedSum(board: Board): int =
  for i in 0..<5:
    let
      unmarked = board.marks[i, _] ==. 0
      line = board.numbers[i, _].squeeze()
    if unmarked.astype(int).sum() == 0:
      continue
    let
      indices = toSeq(0 ..< 5).toTensor()[unmarked.squeeze()]
      numbers = line[indices]
    result.inc numbers.sum()

proc drawOne(board: Board, value: int): Board =
  let newMark = (board.numbers ==. value).astype(int)
  initBoard(board.numbers, board.marks + newMark)

# returns sequence of unmarked sums
proc drawAll(boards: seq[Board], values: seq[int]): seq[int] =
  var
    boards = boards
    doneBoards: seq[int]
  for value in values:
    for i in 0..<boards.len:
      if i in doneBoards:
        continue
      boards[i] = boards[i].drawOne(value)
      if boards[i].iscomplete:
        doneBoards.add i
        result.add boards[i].unmarkedSum * value

day 4:
  var
    lines = read(file)
    values = map(lines[0].split(','), parseInt)
    boards = parseBoards(lines)
    unmarkedSums = boards.drawAll(values)
  part1 = unmarkedSums[0]
  part2 = unmarkedSums[^1]

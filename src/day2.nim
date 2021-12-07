import ./utils
import std/strutils

type
  Direction = enum
    Forward = "forward"
    Down = "down"
    Up = "up"
  Position = object
    x, y: int
    aim: int
  Move = tuple
    direction: Direction
    value: int

proc parse(line: string): Move =
  result.direction = parseEnum[Direction](line.split()[0])
  result.value = parseInt(line.split()[1])

proc moveBy(submarine: var Position, line: string) =
  let move = parse(line)
  case move.direction
  of Forward:
    submarine.x += move.value
  of Down:
    submarine.y += move.value
  of Up:
    submarine.y -= move.value

proc aimBy(submarine: var Position, line: string) =
  let move = parse(line)
  case move.direction
  of Forward:
    submarine.x += move.value
    submarine.y += submarine.aim * move.value
  of Down:
    submarine.aim += move.value
  of Up:
    submarine.aim -= move.value

day 2:
  var submarine1, submarine2: Position
  for line in read(file):
    submarine1.moveBy(line)
    submarine2.aimBy(line)
  part1 = submarine1.x * submarine1.y
  part2 = submarine2.x * submarine2.y

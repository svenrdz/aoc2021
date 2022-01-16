import ./utils
import std/[options, strutils, sequtils, math]

type
  PacketKind = enum
    pkSum = 0
    pkProduct = 1
    pkMinimum = 2
    pkMaximum = 3
    pkLiteral = 4
    pkGreaterThan = 5
    pkLessThan = 6
    pkEqual = 7
  LengthKind = enum
    lkLength lkNumber
  Line = object
    hex: string
    data: string
    cursor: int
  Pack = object
    version: int
    kind: PacketKind
    value: int
    packs: seq[Pack]

proc isEmpty(line: Line): bool =
  line.cursor >= line.data.len

proc read(line: var Line, n: int): string =
  for _ in 0 ..< n:
    result.add line.data[line.cursor]
    inc line.cursor

proc parsePacketKind(line: string): PacketKind =
  PacketKind parseBinInt(line)

proc parseLengthKind(line: string): LengthKind =
  case parseBinInt(line):
    of 0: lkLength
    else: lkNumber

proc initLine(line: string): Line =
  result.hex = line
  for ch in line:
    result.data.add parseHexInt($ch).toBin(4)
  result.cursor = 0

proc initPacket(line: var Line): Pack =
  let
    version = parseBinInt line.read(3)
    kind = parsePacketKind line.read(3)
  Pack(version: version, kind: kind)

proc parse(line: var Line): Pack

proc parseLit(pack: var Pack, line: var Line) =
  var
    valueString: string
    keepGoing = true
  while keepGoing:
    keepGoing = line.read(1) == "1"
    valueString.add line.read(4)
  pack.value = parseBinInt valueString

proc parseOperator(pack: var Pack, line: var Line) =
  let lengthKind = parseLengthKind line.read(1)
  case lengthKind
  of lkLength:
    let length = parseBinInt line.read(15)
    var subline = Line(cursor: 0, data: line.read(length))
    while not subline.isEmpty():
      pack.packs.add parse subline
  of lkNumber:
    let nbPacks = parseBinInt line.read(11)
    for _ in 0 ..< nbPacks:
      pack.packs.add parse line

proc parse(line: var Line): Pack =
  result = initPacket(line)
  case result.kind
  of pkLiteral:
    result.parseLit(line)
  else:
    result.parseOperator(line)

proc versionSum(pack: Pack): int =
  result = pack.version
  for subpack in pack.packs:
    result += subpack.versionSum

proc getValue(pack: Pack): int =
  case pack.kind
  of pkSum:
    for subpack in pack.packs:
      result += getValue subpack
  of pkProduct:
    result = 1
    for subpack in pack.packs:
      result *= getValue subpack
  of pkMinimum, pkMaximum:
    var s: seq[int]
    for subpack in pack.packs:
      s.add getValue subpack
    result = case pack.kind:
      of pkMinimum: s.min
      else: s.max
  of pkLiteral:
    result = pack.value
  of pkGreaterThan, pkLessThan, pkEqual:
    let
      left = getValue pack.packs[0]
      right = getValue pack.packs[1]
    result = case pack.kind:
      of pkGreaterThan: int(left > right)
      of pkLessThan: int(left < right)
      else: int(left == right)

day 16:
  var
    line = initLine read(file)[0]
    pack = parse line
  part1 = pack.versionSum
  part2 = pack.getValue

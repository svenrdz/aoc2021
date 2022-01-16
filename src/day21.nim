import ./utils
import std/[strutils, tables]

type
  Player = object
    pos: int
    score: int

proc parse(file: string): seq[Player] =
  let lines = read file
  for line in lines:
    let pos = parseInt line.split(' ')[^1]
    result.add Player(pos: pos)

iterator items(players: var seq[Player]): var Player =
  var i = 0
  while true:
    yield players[i]
    i = 1 - i

proc mod1(a, b: int): int =
  (a - 1) mod b + 1

proc runDeterministicGame(players: seq[Player]): int =
  var
    players = players
    dice = 1
    totalRolls = 0
    done = false
  for p in players:
    if done:
      return totalRolls * p.score
    let diceSum = dice * 3 + 3
    p.pos = (p.pos + diceSum).mod1 10
    p.score += p.pos
    dice = (dice + 3).mod1 100
    totalRolls.inc 3
    if p.score >= 1000:
      done = true

proc quantumRolls: CountTable[int] =
  for i in 1..3:
    for j in 1..3:
      for k in 1..3:
        result.inc i+j+k

const QuantumRolls = quantumRolls()
echo QuantumRolls

proc runQuantumGame(players: seq[Player], winScore = 21): int =
  var
    playerIdx = 0
    universes: CountTable[array[2, Player]]
    tmp = universes
  universes.inc [players[0], players[1]]
  while true:
    for p, count in universes:
      for dSum, dCount in QuantumRolls:
        var p = p
        p[playerIdx].pos = (p[playerIdx].pos + dSum).mod1 10
        p[playerIdx].score += p[playerIdx].pos
        tmp.inc(p, dCount)
    universes = tmp
    tmp = initCountTable[array[2, Player]]()
    playerIdx = 1 - playerIdx

    block maybeStop:
      for p in universes.keys:
        if p[0].score < winScore and p[1].score < winScore:
          break maybeStop
      echo universes.len
      var scores = [0, 0]
      for p, count in universes:
        let idx =
          if p[0].score > p[1].score:
            0
          else:
            1
        scores[idx] += count
      if scores[0] > scores[1]:
        return scores[0]
      else:
        return scores[1]

day Ex:
  let players = parse file
  part1 = runDeterministicGame players
  part2 = runQuantumGame players

import ./utils
import std/[math, sequtils, strutils]
import arraymancer

type BTensor = Tensor[int]

proc toTensor(path: string): BTensor =
  var
    t: seq[seq[int]]
    l: seq[int]
  for line in path.read:
    l = @[]
    for ch in line:
      l.add parseInt($ch)
    t.add l
  t.toTensor()


proc parseBin(t: BTensor): int =
  parseBinInt(join(toSeq2D(t)[0]))

proc powerConsumption(t: BTensor): int =
  let
    size = t.shape[0]
    bitsize = t.shape[1]
    maxValue = 2 ^ bitsize - 1
    nbOnes = t.sum(0)
    gammaTensor = (nbOnes >. size div 2).astype(int)
    gamma = parseBin(gammaTensor)
    epsilon = maxValue - gamma
  result = gamma * epsilon

proc filter(t: BTensor, idx, keepValue: int): BTensor =
  let
    mask = t[_, idx] ==. keepValue
    indices = toSeq(0..<mask.size).toTensor()[mask.squeeze()]
  t[indices, _]

proc lifeSupportRating(t: BTensor): int =
  var
    tensorO2 = t
    tensorCO2 = t
  let bitsize = t.shape[1]
  for idx in 0..<bitsize:
    let
      sizeO2 = tensorO2.shape[0]
      sizeCO2 = tensorCO2.shape[0]
    if sizeO2 == 1 and sizeCO2 == 1:
      break
    if sizeO2 > 1:
      let
        nbOnes = tensorO2[_, idx].sum().float
        keepValue = nbOnes >= sizeO2 / 2 ? 1: 0
      tensorO2 = tensorO2.filter(idx, keepValue)
    if sizeCO2 > 1:
      let
        nbOnes = tensorCO2[_, idx].sum().float
        keepValue = nbOnes >= sizeCO2 / 2 ? 0: 1
      tensorCO2 = tensorCO2.filter(idx, keepValue)
  parseBin(tensorO2) * parseBin(tensorCO2)

day 3:
  let tensor = file.toTensor()
  part1 = tensor.powerConsumption
  part2 = tensor.lifeSupportRating

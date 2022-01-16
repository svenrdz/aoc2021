import ./utils
import std/[strutils]

type
  Area = object
    x: HSlice[int, int]
    y: HSlice[int, int]
  Probe = object
    x, y: int
    vx, vy: int

proc step(probe: var Probe) =
  probe.x += probe.vx
  probe.y += probe.vy
  let mx = case probe.vx:
    of 1 .. int.high: -1
    of 0: 0
    of int.low .. -1: 1
  probe.vx += mx
  probe.vy -= 1

proc initArea(x = int.low .. int.high, y = int.low .. int.high): Area =
  result.x = x
  result.y = y

proc parse(file: string): Area =
  let
    line = read(file)[0]
    pair = line.split("target area: ")[1].split(", ")
    xpair = pair[0].split("=")[1].split("..")
    ypair = pair[1].split("=")[1].split("..")
    xlow = parseInt xpair[0]
    xhigh = parseInt xpair[1]
    ylow = parseInt ypair[0]
    yhigh = parseInt ypair[1]
  initArea(xlow .. xhigh, ylow .. yhigh)

proc contains(area: Area, probe: Probe): bool =
  (probe.x in area.x) and (probe.y in area.y)

proc overshot(probe: Probe, area: Area): bool =
  if probe.y < area.y.a:
    return true
  if probe.x > area.x.b:
    return true
  if (probe.x < area.x.a) and (probe.vx == 0):
    return true
  false

proc goesIn(probe: Probe, area: Area): bool =
  var probe = probe
  while true:
    if probe in area:
      return true
    if probe.overshot area:
      return false
    step probe

proc initProbe(x = 0, y = 0, vx = 0, vy = 0): Probe =
  result.x = x
  result.y = y
  result.vx = vx
  result.vy = vy

proc vy(area: Area): seq[int] =
  var areaAnyX = initArea(y = area.y)
  for vy in -100 .. 100:
    let probe = initProbe(vy = vy)
    if probe.goesIn areaAnyX:
      result.add vy

proc vx(area: Area): seq[int] =
  var areaAnyY = initArea(x = area.x)
  for vx in 0 .. 1000:
    let probe = initProbe(vx = vx)
    if probe.goesIn areaAnyY:
      result.add vx

proc successfulProbes(area: Area): seq[Probe] =
  for vy in area.vy:
    for vx in area.vx:
      let probe = initProbe(vx = vx, vy = vy)
      if probe.goesIn area:
        result.add probe

proc maxHeight(probes: seq[Probe]): int =
  var tops: seq[int]
  for letprobe in probes:
    var
      maxTop = 0
      top = 0
      probe = letprobe
    while top >= maxTop:
      step probe
      top = probe.y
      if top > maxTop:
        maxTop = top
    tops.add maxTop
  tops.max

day 17:
  let
    area = parse file
    probes = area.successfulProbes
  part1 = probes.maxHeight
  part2 = probes.len

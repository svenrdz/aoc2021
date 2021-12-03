import os
import strutils
import nake

var latest: int = 0
for f in walkFiles("day*"):
  let day = parseInt(f[3..^5])
  if day > latest:
    latest = day

task defaultTask, "Run latest day":
  discard shell(nimExe, "r", "day" & $latest & ".nim")

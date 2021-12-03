import os
import nake
import macros
import strutils

var latest: int = 0
for f in walkFiles("day*"):
  let day = parseInt(f[3..^5])
  if day > latest:
    latest = day

task defaultTask, "Run latest day":
  discard shell(nimExe, "r", "day" & $latest & ".nim")

macro makeDayTasks: untyped =
  result = newStmtList()
  for day in 1..25:
    result.add quote do:
      task $`day`, "Run day " & $`day`:
        discard shell(nimExe, "r", "day" & $`day` & ".nim")

makeDayTasks()

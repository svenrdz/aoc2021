import os
import nake
import macros
import strutils

var days: seq[int]
for f in walkFiles("day*"):
  let day = parseInt(f[3..^5])
  days.add day

proc runDay(day: int) =
  discard shell(nimExe, "r", "--hints:off", "day" & $day & ".nim")

task defaultTask, "Run latest day":
  runDay(max(days))

macro makeDayTasks: untyped =
  result = newStmtList()
  for day in 1..25:
    result.add quote do:
      task $`day`, "Run day " & $`day`:
        runDay(`day`)

makeDayTasks()

task "all", "Run all days":
  for day in days:
    runDay(day)

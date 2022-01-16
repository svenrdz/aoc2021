import nake
import std/[os, macros, strutils]

var days: seq[int]
for f in walkFiles("src/day*"):
  let day = parseInt(f[7..^5])
  days.add day

proc runDay(day: int) =
  discard shell(nimExe, "r", "--gc:orc --hints:off", "src/day" & $day & ".nim")

task defaultTask, "Run latest day":
  runDay(max(days))

task "all", "Run all days":
  for day in days:
    runDay(day)

macro makeDayTasks: untyped =
  result = newStmtList()
  for day in 1..25:
    result.add quote do:
      task $`day`, "Run day " & $`day`:
        runDay(`day`)

makeDayTasks()

import ./utils
import std/strutils
import arraymancer

type
  Node = tuple[dest, risk: int]
  Cavern = object
    edges: seq[seq[Node]]
    distances: seq[int]

proc index(size: int, i, j: int): int = i * size + j

proc parse(file: string): Tensor[int] =
  let
    lines = read file
    size = lines.len
  result = zeros[int](size, size)
  for i, line in lines:
    for j, ch in line:
      result[i, j] = parseInt $ch

proc makeCavern(grid: Tensor[int]): Cavern =
  let size = grid.shape[0]
  for i in 0 ..< size:
    for j in 0 ..< size:
      var edges: seq[Node] = @[]
      if i > 0:
        edges.add (index(size, i - 1, j), grid[i - 1, j])
      if j > 0:
        edges.add (index(size, i, j - 1), grid[i, j - 1])
      if i < size - 1:
        edges.add (index(size, i + 1, j), grid[i + 1, j])
      if j < size - 1:
        edges.add (index(size, i, j + 1), grid[i, j + 1])
      result.edges.add edges
      result.distances.add 1_000_000
  result.distances[0] = 0

proc dijkstra(cavern: Cavern): Cavern =
  result = cavern
  var queue: seq[int]
  for i in 0 ..< cavern.edges.len:
    queue.add i
  while queue.len > 0:
    var start = queue[0]
    for i in queue:
      if result.distances[i] < result.distances[start]:
        start = i
    let
      idx = queue.find(start)
      u = queue[idx]
    queue.delete(idx)
    for edge in result.edges[u]:
      if result.distances[edge[0]] > (result.distances[u] + edge[1]):
        result.distances[edge[0]] = result.distances[u] + edge[1]

proc repeatGrid(grid: Tensor[int]): Tensor[int] =
  result = grid
  result = concat(result, result +. 1, result +. 2, result +. 3, result +. 4, 0)
  result = concat(result, result +. 1, result +. 2, result +. 3, result +. 4, 1)
  for i in 0 ..< result.shape[0]:
    for j in 0 ..< result.shape[1]:
      if result[i, j] > 9:
        result[i, j] -= 9

day 15:
  let
    basicGrid = parse file
    complexGrid = repeatGrid(basicGrid)
  part1 = makeCavern(basicGrid).dijkstra.distances[^1]
  part2 = makeCavern(complexGrid).dijkstra.distances[^1]

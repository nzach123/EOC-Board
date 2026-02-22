extends Node
## Breath first search
# Converts an offset-coordinate cell, to cube coordinates. (Vector3i)
func _offset_to_cube(hex: Vector2i) -> Vector3i:
	var col: int = hex.x
	var row: int = hex.y
	var q: int = col
	var r: int = row - (col - (col & 1)) / 2
	var s: int = -q -r
	return Vector3i(q, r, s)

# Converts cube coordinates back to offset-coordinate cell (Vector2i)
func _cube_to_offset(cube: Vector3i) -> Vector2i:
	var col: int = cube.x
	var row: int = cube.y + (cube.x - (cube.x & 1)) /2
	return Vector2i(col,row)
	
## Returns an Array of Vector2i offset-cells within "radius" steps of "Centre"
func _get_cells_in_range(tilemap: TileMapLayer, start: Vector2i, movement: int) -> Array[Vector2i]:
	var visited: Dictionary = {start: true}
	var fringes: Array[Array] = [[start]]
	
	for k in range(1, movement + 1):
		fringes.append([])
		for hex in fringes[k - 1]:
			for neighbor in tilemap.get_surrounding_cells(hex):
				if not visited.has(neighbor):
					if tilemap.get_cell_source_id(neighbor) != -1:
						visited[neighbor] = true
						fringes[k].append(neighbor)
	var results: Array[Vector2i] = []
	for cell in visited.keys():
		results.append(cell)
	return results
			

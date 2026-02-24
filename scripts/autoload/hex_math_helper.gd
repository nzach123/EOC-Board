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
	
## Returns an Array of Vector2i offset-cells reachable within "movement" budget,
## respecting per-tile movement_cost custom data (Dijkstra flood fill).
func _get_cells_in_range(tilemap: TileMapLayer, start: Vector2i, movement: int) -> Array[Vector2i]:
	var cost_so_far: Dictionary = {start: 0}
	var frontier: Array[Vector2i] = [start]

	while frontier.size() > 0:
		# Pop the cheapest cell (simple priority queue)
		var best_idx := 0
		for i in range(1, frontier.size()):
			if cost_so_far[frontier[i]] < cost_so_far[frontier[best_idx]]:
				best_idx = i
		var current: Vector2i = frontier[best_idx]
		frontier.remove_at(best_idx)

		for neighbor in tilemap.get_surrounding_cells(current):
			if tilemap.get_cell_source_id(neighbor) == -1:
				continue
			var tile_data: TileData = tilemap.get_cell_tile_data(neighbor)
			var tile_cost: int = 1
			if tile_data:
				tile_cost = maxi(tile_data.get_custom_data("move_cost"), 1)
			var new_cost: int = cost_so_far[current] + tile_cost
			if new_cost <= movement and (not cost_so_far.has(neighbor) or new_cost < cost_so_far[neighbor]):
				cost_so_far[neighbor] = new_cost
				frontier.append(neighbor)

	var results: Array[Vector2i] = []
	for cell in cost_so_far.keys():
		results.append(cell)
	return results
			

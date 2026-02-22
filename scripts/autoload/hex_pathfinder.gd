extends Node

@export var tile_layer: TileMapLayer

var astar := AStar2D.new()
var cell_to_id: Dictionary = {}
var id_to_cell: Dictionary = {}

var next_id := 0

func rebuild_graph(is_walkable: Callable) -> void:
	astar.clear()
	cell_to_id.clear()
	id_to_cell.clear()
	var next_id := 0
	for cell in tile_layer.get_used_cells():
		if is_walkable.call(cell):
			cell_to_id[cell] = next_id
			id_to_cell[next_id] = cell
			astar.add_point(next_id, tile_layer.map_to_local(cell))
			next_id += 1
	for cell in cell_to_id.keys():
		var id = cell_to_id[cell]
		for n in tile_layer.get_surrounding_cells(cell):
			if cell_to_id.has(n):
				astar.connect_points(id, cell_to_id[n])
	print("HexPathfinder: ", astar.get_point_count(), " walkable cells")
	
func cell_to_world(cell: Vector2i) -> Vector2:
	return tile_layer.to_global(tile_layer.map_to_local(cell))
	
func world_to_cell(world_pos: Vector2) -> Vector2i:
	return tile_layer.local_to_map(tile_layer.to_local(world_pos))

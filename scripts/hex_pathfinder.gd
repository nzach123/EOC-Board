extends Node
class_name HexPathfinder
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

func has_cell(cell: Vector2i) -> bool:
	return cell_to_id.has(cell) 

func get_cell_path(from_cell: Vector2i, to_cell: Vector2i) -> Array[Vector2i]:
	var from_id: int = cell_to_id[from_cell]
	var to_id: int = cell_to_id[to_cell]
	var id_path := astar.get_id_path(from_id, to_id)
	var cell_path: Array[Vector2i] = []
	for id in id_path:
		cell_path.append(id_to_cell[id])
	return cell_path
func cell_to_world(cell: Vector2i) -> Vector2:
	return tile_layer.to_global(tile_layer.map_to_local(cell))
	
func world_to_cell(world_pos: Vector2) -> Vector2i:
	return tile_layer.local_to_map(tile_layer.to_local(world_pos))

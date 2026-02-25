extends Node
class_name UnitMovementExecutor

var selection_manager: UnitSelectionManager
var range_highlighter: MovementRangeHighlighter
var hex_pathfinder: HexPathfinder
var nav: UnitNavMovement
var base_layer: TileMapLayer

var _pending_path_cost: int = 0

signal movement_completed()



func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed():
		_move_selected_unit_to_mouse_tile()

func _move_selected_unit_to_mouse_tile() -> void:
	if not is_instance_valid(selection_manager.selected_unit):
		return
	var cell: Vector2i = base_layer.local_to_map(base_layer.get_local_mouse_position())
	if not range_highlighter.is_cell_reachable(cell):
		range_highlighter.clear()
		print("Cell outside movement range: ", cell)
		return
	var original_cell: Vector2i = base_layer.local_to_map(
		base_layer.to_local(selection_manager.selected_unit.global_position))
	var path: Array[Vector2i] = hex_pathfinder.get_cell_path(original_cell, cell)
	_pending_path_cost = 0
	for i in range(1, path.size()):
		var tile_data: TileData = base_layer.get_cell_tile_data(path[i])
		if tile_data:
			_pending_path_cost += maxi(tile_data.get_custom_data("move_cost"), 1)
		else:
			_pending_path_cost += 1
	nav.move_to_cell(cell)
	range_highlighter.clear()

func _on_unit_arrived() -> void:
	if not is_instance_valid(selection_manager.selected_unit):
		return
	selection_manager.selected_unit.deduct_movement(_pending_path_cost)
	_pending_path_cost = 0
	movement_completed.emit()

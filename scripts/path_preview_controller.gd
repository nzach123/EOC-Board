extends Node
class_name PathPreviewController

var _preview_path: PackedVector2Array = PackedVector2Array()
var _last_hover_cell: Vector2i = Vector2i(-99999, -99999)

# Set by the orchestrator after wiring
var selection_manager: UnitSelectionManager
var range_highlighter: MovementRangeHighlighter
var hex_pathfinder: HexPathfinder
var debug_manager: UnitDebugManager
var base_layer: TileMapLayer

func _process(_delta: float) -> void:
	if selection_manager.selected_unit == null or range_highlighter.get_reachable_cells().is_empty():
		if not _preview_path.is_empty():
			_preview_path.clear()
			debug_manager.set_preview_path(_preview_path)
		return

	var mouse_cell: Vector2i = base_layer.local_to_map(base_layer.get_local_mouse_position())
	if mouse_cell == _last_hover_cell:
		return
	_last_hover_cell = mouse_cell

	if not range_highlighter.is_cell_reachable(mouse_cell):
		_preview_path.clear()
		debug_manager.set_preview_path(_preview_path)
		return

	var unit_cell: Vector2i = base_layer.local_to_map(
		base_layer.to_local(selection_manager.selected_unit.global_position))
	if not hex_pathfinder.has_cell(unit_cell) or not hex_pathfinder.has_cell(mouse_cell):
		_preview_path.clear()
		debug_manager.set_preview_path(_preview_path)
		return

	var cell_path: Array[Vector2i] = hex_pathfinder.get_cell_path(unit_cell, mouse_cell)
	_preview_path.clear()
	for cell in cell_path:
		_preview_path.append(hex_pathfinder.cell_to_world(cell))
	debug_manager.set_preview_path(_preview_path)

func reset() -> void:
	_preview_path.clear()
	_last_hover_cell = Vector2i(-99999, -99999)
	debug_manager.set_preview_path(_preview_path)

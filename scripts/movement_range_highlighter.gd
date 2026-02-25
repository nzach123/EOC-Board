extends Node
class_name MovementRangeHighlighter

@export var highlight_layer: TileMapLayer
@export var base_layer: TileMapLayer

var _reachable_cells: Array[Vector2i] = []
var _reachable_set: Dictionary = {}

signal range_cleared()

func show_range(unit: Node2D) -> void:
	clear()
	var unit_cell: Vector2i = base_layer.local_to_map(base_layer.to_local(unit.global_position))
	_reachable_cells = HexMathHelper._get_cells_in_range(base_layer, unit_cell, unit.movement_remaning)
	_reachable_set.clear()
	for cell in _reachable_cells:
		_reachable_set[cell] = true
		highlight_layer.set_cell(cell, 3, Vector2i.ZERO)

func clear() -> void:
	highlight_layer.clear()
	_reachable_cells.clear()
	_reachable_set.clear()
	range_cleared.emit()

func is_cell_reachable(cell: Vector2i) -> bool:
	return _reachable_set.has(cell)

func get_reachable_cells() -> Array[Vector2i]:
	return _reachable_cells

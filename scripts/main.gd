extends Node2D

@onready var hex_pathfinder: HexPathfinder = $HexPathfinder
@onready var nav: UnitNavMovement = $Unit/NavMovement
@onready var debug_manager: UnitDebugManager = $UnitDebugManager

@onready var base_terrian_layer: TileMapLayer = $BaseTerrianLayer
@onready var crisis_terrian_layer: TileMapLayer = $CrisisTerrianLayer
@onready var highlight_terrian_layer: TileMapLayer = $HighlightTerrianLayer

@onready var unit_node: Node2D = $Unit

var selected_unit: Node2D = null
var move_tween: Tween
var _reachable_cells: Array[Vector2i] = []
var _reachable_set: Dictionary = {}
var _pending_path_cost: int = 0
var _preview_path: PackedVector2Array = PackedVector2Array()
var _last_hover_cell: Vector2i = Vector2i(-99999, -99999)

func _ready() -> void:
	unit_node.left_clicked.connect(_on_unit_left_clicked)
# Build the pathfinder graph — here's the is_walkable Callable:
	hex_pathfinder.rebuild_graph(func(cell: Vector2i) -> bool:
		return base_terrian_layer.get_cell_source_id(cell) != -1)
	# Wire up nav movement
	nav.setup(hex_pathfinder)
	nav.path_completed.connect(_on_unit_arrived)
	nav.path_failed.connect(func(reason: String): print("Path failed: ", reason))
	# Wire up debug manager to receive path updates
	nav.path_updated.connect(debug_manager._on_unit_path_updated)	
	
func _on_unit_arrived()-> void:
	
	if not is_instance_valid(selected_unit):
		return
	selected_unit.deduct_movement(_pending_path_cost)
	_pending_path_cost = 0
	

func _on_unit_left_clicked(unit: Node2D) -> void:
	selected_unit = unit
	debug_manager.set_active_unit(unit)
	print("Selected unit: ", unit.name)
	_show_movement_range(unit)

func _process(_delta: float) -> void:
	if not is_instance_valid(selected_unit) or _reachable_cells.is_empty():
		if not _preview_path.is_empty():
			_preview_path.clear()
			debug_manager.set_preview_path(_preview_path)
		return

	var mouse_cell: Vector2i = base_terrian_layer.local_to_map(
		base_terrian_layer.get_local_mouse_position())

	# Skip recalc if still on the same cell
	if mouse_cell == _last_hover_cell:
		return
	_last_hover_cell = mouse_cell

	# Only preview if mouse is inside the reachable area (O(1) lookup)
	if not _reachable_set.has(mouse_cell):
		_preview_path.clear()
		debug_manager.set_preview_path(_preview_path)
		return

	var unit_cell: Vector2i = base_terrian_layer.local_to_map(
		base_terrian_layer.to_local(selected_unit.global_position))

	# Guard: both cells must be in the pathfinder graph
	if not hex_pathfinder.has_cell(unit_cell) or not hex_pathfinder.has_cell(mouse_cell):
		_preview_path.clear()
		debug_manager.set_preview_path(_preview_path)
		return

	var cell_path: Array[Vector2i] = hex_pathfinder.get_cell_path(unit_cell, mouse_cell)

	_preview_path.clear()
	for cell in cell_path:
		_preview_path.append(hex_pathfinder.cell_to_world(cell))

	debug_manager.set_preview_path(_preview_path)

func _unhandled_input(event: InputEvent) -> void:
	# Right click prints tile coordinates
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed():
		_move_selected_unit_to_mouse_tile()
		_print_hex_tile_coords()

func _move_selected_unit_to_mouse_tile() -> void:
	if not is_instance_valid(selected_unit):
		return
	var cell: Vector2i = base_terrian_layer.local_to_map(base_terrian_layer.get_local_mouse_position())
	if cell not in _reachable_cells:
		_clear_highlights()
		print("Cell outside movement range: ", cell)
		return
	var original_cell: Vector2i = base_terrian_layer.local_to_map(base_terrian_layer.to_local(selected_unit.global_position))
	var path: Array[Vector2i] = hex_pathfinder.get_cell_path(original_cell, cell)
	_pending_path_cost = 0
	for i in range(1, path.size()):  # skip the starting tile
		var tile_data: TileData = base_terrian_layer.get_cell_tile_data(path[i])
		if tile_data:
			_pending_path_cost += maxi(tile_data.get_custom_data("move_cost"), 1)
		else:
			_pending_path_cost += 1  # fallback
	nav.move_to_cell(cell)
	_clear_highlights()


func _show_movement_range(unit: Node2D) -> void:
	_clear_highlights()
	var unit_local: Vector2 = base_terrian_layer.to_local(unit.global_position)
	var unit_cell: Vector2i = base_terrian_layer.local_to_map(unit_local)
	var cells_in_range: Array[Vector2i] = HexMathHelper._get_cells_in_range(base_terrian_layer, unit_cell, unit.movement_remaning)
	_reachable_cells = cells_in_range
	_reachable_set.clear()
	for cell in cells_in_range:
		_reachable_set[cell] = true
	for cell in cells_in_range:
		highlight_terrian_layer.set_cell(cell, 3, Vector2i.ZERO)
		
func _clear_highlights() -> void:
	highlight_terrian_layer.clear()
	_reachable_cells.clear()
	_reachable_set.clear()
	_preview_path.clear()
	_last_hover_cell = Vector2i(-99999, -99999)
	debug_manager.set_preview_path(_preview_path)
	
	
# Hex Tiles Debug
func _print_hex_tile_coords() -> void:
	var cell: Vector2i = base_terrian_layer.local_to_map(base_terrian_layer.get_local_mouse_position())
	var atlas_coords := base_terrian_layer.get_cell_atlas_coords(cell)
	var alt_id := base_terrian_layer.get_cell_alternative_tile(cell)

	var tile_source_id: int = base_terrian_layer.get_cell_source_id(cell)
	if tile_source_id == -1:
		print("Clicked empty cell", cell)
		return
	print("Cell Coords:", cell," Atlus Coords:", atlas_coords," Source ID: ", tile_source_id," Alt ID: ", alt_id)
	
	

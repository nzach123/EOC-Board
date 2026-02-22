extends Node2D

@onready var hex_pathfinder: HexPathfinder = $HexPathfinder
@onready var nav: UnitNavMovement = $Unit/NavMovement

@onready var base_terrian_layer: TileMapLayer = $BaseTerrianLayer
@onready var crisis_terrian_layer: TileMapLayer = $CrisisTerrianLayer
@onready var highlight_terrian_layer: TileMapLayer = $HighlightTerrianLayer

@onready var unit_node: Node2D = $Unit

var selected_unit: Node2D = null
var move_tween: Tween
var _reachable_cells: Array[Vector2i] = []

func _ready() -> void:
	unit_node.left_clicked.connect(_on_unit_left_clicked)
# Build the pathfinder graph — here's the is_walkable Callable:
	hex_pathfinder.rebuild_graph(func(cell: Vector2i) -> bool:
		return base_terrian_layer.get_cell_source_id(cell) != -1)
	# Wire up nav movement
	nav.setup(hex_pathfinder)
	nav.path_completed.connect(func(): print("Unit arrived!"))
	nav.path_failed.connect(func(reason: String): print("Path failed: ", reason))	
	
func _on_unit_left_clicked(unit: Node2D) -> void:
	selected_unit = unit
	print("Selected unit: ", unit.name)
	_show_movement_range(unit)

func _unhandled_input(event: InputEvent) -> void:
	# Right click prints tile coordinates
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed():
		_move_selected_unit_to_mouse_tile()
		_print_hex_tile_coords()

func _move_selected_unit_to_mouse_tile() -> void:
	if not is_instance_valid(selected_unit):
		return
		_clear_highlights()
	var cell: Vector2i = base_terrian_layer.local_to_map(base_terrian_layer.get_local_mouse_position())
	if cell not in _reachable_cells:
		print("Cell outside movement range: ", cell)
		return
	nav.move_to_cell(cell)


func _show_movement_range(unit: Node2D) -> void:
	_clear_highlights()
	var unit_local: Vector2 = base_terrian_layer.to_local(unit.global_position)
	var unit_cell: Vector2i = base_terrian_layer.local_to_map(unit_local)
	var cells_in_range: Array[Vector2i] = HexMathHelper._get_cells_in_range(base_terrian_layer, unit_cell, unit.movement_turns)
	_reachable_cells = cells_in_range
	for cell in cells_in_range:
		highlight_terrian_layer.set_cell(cell, 3, Vector2i.ZERO)
		
			
func _clear_highlights() -> void:
	highlight_terrian_layer.clear()
	_reachable_cells.clear()
	
	
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
	
	

extends Node2D

@onready var hex_pathfinder: HexPathfinder = $Componets/HexPathfinder
@onready var nav: UnitNavMovement = $Unit/NavMovement
@onready var debug_manager: UnitDebugManager = $Componets/UnitDebugManager
@onready var base_terrian_layer: TileMapLayer = $BaseTerrianLayer

@onready var unit_node: Node2D = $Unit
@onready var selection: UnitSelectionManager = $Componets/UnitSelectionManager
@onready var highlighter: MovementRangeHighlighter = $Componets/MovementRangeHighlighter
@onready var preview: PathPreviewController = $Componets/PathPreviewController
@onready var executor: UnitMovementExecutor = $Componets/UnitMovementExecutor
@onready var mousetilehighlighter: MouseTileHighlighter = $Componets/MouseTileHighlightManager
@onready var highlight_tile_layer: TileMapLayer = $HighlightTileLayer

@onready var interact_manager: UnitInteractManager = $Componets/UnitInteractManager
@onready var crisis_tile_logic: CrisisTileLogic = $Componets/CrisisTileLogic
@onready var interact_button: Button = $CanvasLayer/Control/MarginContainer/VBoxContainer/HBoxContainer/InteractButton

@onready var camera: RTSCamera = $Camera2D

func _ready() -> void:
	# 1. Pathfinder
	hex_pathfinder.rebuild_graph(func(cell: Vector2i) -> bool:
		return base_terrian_layer.get_cell_source_id(cell) != -1)
	nav.setup(hex_pathfinder)
	nav.path_updated.connect(debug_manager._on_unit_path_updated)
	nav.path_failed.connect(func(reason: String): print("Path failed: ", reason))

	# 2. Wire selection → highlighter + debug
	unit_node.left_clicked.connect(func(unit: Node2D):
		selection.select(unit)
		debug_manager.set_active_unit(unit)
		highlighter.show_range(unit))

	# 3. Inject dependencies into preview controller
	preview.selection_manager = selection
	preview.range_highlighter = highlighter
	preview.hex_pathfinder = hex_pathfinder
	preview.debug_manager = debug_manager
	preview.base_layer = base_terrian_layer

	# 4. Inject dependencies into movement executor
	executor.selection_manager = selection
	executor.range_highlighter = highlighter
	executor.hex_pathfinder = hex_pathfinder
	executor.nav = nav
	executor.base_layer = base_terrian_layer
	executor.mouse_tile_highlighter = mousetilehighlighter
	nav.path_completed.connect(executor._on_unit_arrived)

	# 5. When range is cleared, reset preview
	highlighter.range_cleared.connect(preview.reset)
	
	# 6. Setup Mouse Tile Highlighter
	mousetilehighlighter.highlight_layer = highlight_tile_layer
	mousetilehighlighter.base_layer = base_terrian_layer
	nav.path_completed.connect(mousetilehighlighter.clear_destination)

	# 7. Wire interact manager
	interact_manager.selection_manager = selection
	interact_manager.crisis_tile_logic = crisis_tile_logic
	interact_manager.base_layer = base_terrian_layer
	interact_manager.interact_button = interact_button
	interact_manager.setup()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed():
		_print_hex_tile_coords()

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

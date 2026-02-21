extends Node2D


@onready var base_terrian_layer: TileMapLayer = $BaseTerrianLayer
@onready var crisis_terrian_layer: TileMapLayer = $CrisisTerrianLayer
@onready var highlight_terrian_layer: TileMapLayer = $HighlightTerrianLayer

var cell: Vector2i
var tile_source_id: int = -1

func _ready() -> void:
	return
	
func _unhandled_input(event: InputEvent) -> void:
	# Left click prints tile coordinates
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed():
		_print_hex_tile_coords()
		
		
		
func _print_hex_tile_coords() -> void:
	var cell = base_terrian_layer.local_to_map(base_terrian_layer.get_local_mouse_position())
	var atlas_coords := base_terrian_layer.get_cell_atlas_coords(cell)
	var alt_id := base_terrian_layer.get_cell_alternative_tile(cell)

	tile_source_id = base_terrian_layer.get_cell_source_id(cell)
	if tile_source_id == -1:
		print("Clicked empty cell", cell)
		return
	print("Cell Coords:", cell," Atlus Coords:", atlas_coords," Source ID: ", tile_source_id," Alt ID: ", alt_id)
	
	

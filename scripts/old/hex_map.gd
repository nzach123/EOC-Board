extends TileMapLayer

@export var grid_weidth: int = 28
@export var grid_height: int = 15

@export var terrain_source_id: int = 1
@export var terrain_atlas_coords: Vector2i = Vector2i(0, 0)
@export var terrain_alternative: int = 0


var cell_data_by_cell: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_generate_grid()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _generate_grid() -> void:
	clear()
	cell_data_by_cell.clear()
	
	for row in range(grid_height):
		for col in range(grid_weidth):
			var cell := Vector2i(col, row)
			set_cell(cell, terrain_source_id, terrain_atlas_coords, terrain_alternative) 
			
			#var id := id_from_row_col(row, col)
	print("Hexagonal board populated: %d x %d" % [grid_weidth, grid_height])

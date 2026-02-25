extends Node
class_name MouseTileHighlighter

@export var highlight_layer: TileMapLayer
@export var base_layer: TileMapLayer

var _last_hover_cell: Vector2i = Vector2i(-99999, -99999) # invalid cell
var _destination_cell: Vector2i = Vector2i(-99999, -99999)

func _process(_delta: float) -> void:
	if not is_instance_valid(highlight_layer) or not is_instance_valid(base_layer):
		return

	var cell: Vector2i = base_layer.local_to_map(base_layer.get_local_mouse_position())
	
	# Only update if the hovered cell has changed
	if cell != _last_hover_cell:
		# Clear previous hover if it's not the destination cell
		if _last_hover_cell != _destination_cell and _last_hover_cell != Vector2i(-99999, -99999):
			highlight_layer.set_cell(_last_hover_cell, -1, Vector2i(-1, -1)) # Clear
			
		_last_hover_cell = cell
		
		# Draw new hover if it's not the destination cell
		if cell != _destination_cell:
			highlight_layer.set_cell(cell, 0, Vector2i(0, 0)) # Yellow highlight (Source 0)

func set_destination(cell: Vector2i) -> void:
	# Clear old destination if it exists
	if _destination_cell != Vector2i(-99999, -99999):
		highlight_layer.set_cell(_destination_cell, -1, Vector2i(-1, -1))
		
	_destination_cell = cell
	highlight_layer.set_cell(cell, 0, Vector2i(0, 0)) # Yellow highlight
	
func clear_destination() -> void:
	if _destination_cell != Vector2i(-99999, -99999):
		highlight_layer.set_cell(_destination_cell, -1, Vector2i(-1, -1))
		
		# If the mouse is still over the old destination cell, re-highlight it as hover
		if _last_hover_cell == _destination_cell:
			highlight_layer.set_cell(_last_hover_cell, 0, Vector2i(0, 0))
			
		_destination_cell = Vector2i(-99999, -99999)

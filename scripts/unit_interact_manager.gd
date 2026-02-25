extends Node
class_name UnitInteractManager

## Injected by main.gd
var selection_manager: UnitSelectionManager
var crisis_tile_logic: CrisisTileLogic
var base_layer: TileMapLayer          # BaseTerrianLayer
var interact_button: Button

## Tracks the adjacent crisis cell (sentinel = no adjacent crisis).
var _adjacent_crisis_cell: Vector2i = Vector2i(-1, -1)

## Call after injecting all dependencies from main.gd.
func setup() -> void:
	interact_button.visible = false
	interact_button.pressed.connect(_on_interact_pressed)

func _process(_delta: float) -> void:
	_update_interact_visibility()

## Show the Interact button when the selected unit is adjacent to a crisis tile.
func _update_interact_visibility() -> void: ## move to a ui debugger manager
	if not is_instance_valid(selection_manager.selected_unit):
		interact_button.visible = false
		return

	var unit_cell: Vector2i = base_layer.local_to_map(
		base_layer.to_local(selection_manager.selected_unit.global_position))

	for neighbor in base_layer.get_surrounding_cells(unit_cell):
		if crisis_tile_logic.is_crisis_cell(neighbor):
			_adjacent_crisis_cell = neighbor
			interact_button.visible = true
			return

	_adjacent_crisis_cell = Vector2i(-1, -1)
	interact_button.visible = false

## Compare unit attack vs crisis defense and print the result.
func _on_interact_pressed() -> void:
	var unit = selection_manager.selected_unit
	if not is_instance_valid(unit):
		return
	if unit.attack >= crisis_tile_logic.defense:
		print("win")
	else:
		print("lose")

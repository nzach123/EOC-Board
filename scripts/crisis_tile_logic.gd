extends Node
class_name CrisisTileLogic

@export var defense: int = 7
@export var health: int = 50
@onready var crisis_terrian_layer: TileMapLayer = $"../../CrisisTerrianLayer"

## Returns true if the given cell has a crisis tile painted on the CrisisTerrianLayer.
func is_crisis_cell(cell: Vector2i) -> bool:
	return crisis_terrian_layer.get_cell_source_id(cell) != -1

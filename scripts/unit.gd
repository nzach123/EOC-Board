extends Node2D

@onready var click_area: Area2D = $ClickArea

signal left_clicked(unit: Node2D)

@export var movement_turns: int = 4
@export var defense: int = 5
@export var attack: int = 9

@onready var base_terrian_layer: TileMapLayer = $"../BaseTerrianLayer"
@onready var crisis_terrian_layer: TileMapLayer = $"../CrisisTerrianLayer"

var movement_remaning: int = movement_turns

func _ready() -> void:
	movement_remaning = movement_turns

func deduct_movement(cost: int) -> void:
	movement_remaning = max(movement_remaning - cost, 0)
	
func _on_click_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		left_clicked.emit(self)
		
func _reset_movement() -> void:
	movement_remaning = movement_turns


func _on_next_turn_button_pressed() -> void:
	movement_remaning = movement_turns

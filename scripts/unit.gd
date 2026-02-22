extends Node2D

@onready var click_area: Area2D = $ClickArea

signal left_clicked(unit: Node2D)

@export var movement_turns: int = 4

func _ready() -> void:
	return


func _on_click_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		left_clicked.emit(self)
		

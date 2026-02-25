extends Node
class_name UnitSelectionManager

signal unit_selected(unit: Node2D)
signal unit_deselected()

var selected_unit: Node2D = null

func select(unit: Node2D) -> void:
	selected_unit = unit
	unit_selected.emit(unit)

func deselect() -> void:
	selected_unit = null
	unit_deselected.emit()

extends Node2D
class_name UnitDebugManager

# Maintain a list of units we want to draw paths for.
# You can append to this when selecting units, or keep it tracking all units.
var active_units: Array[Node2D] = []

func _ready() -> void:
	z_index = 100
	top_level = true

# Call this from your main/world script when a unit is selected
func set_active_unit(unit: Node2D) -> void:
	active_units.clear()
	if unit:
		active_units.append(unit)
	queue_redraw()

# Connect ALL spawned units to this function: 
# unit.get_node("UnitNavMovement").path_updated.connect(debug_manager._on_unit_path_updated)
func _on_unit_path_updated(unit: Node2D) -> void:
	if unit in active_units:
		queue_redraw()

func _process(_delta: float) -> void:
	var needs_redraw := false
	for unit in active_units:
		if is_instance_valid(unit) and unit.has_node("NavMovement"):
			var nav: UnitNavMovement = unit.get_node("NavMovement")
			if nav._state == UnitNavMovement.State.MOVING:
				needs_redraw = true
				break
	if needs_redraw:
		queue_redraw()

func _draw() -> void:
	for unit in active_units:
		if not is_instance_valid(unit) or not unit.has_node("NavMovement"):
			continue
			  
		var nav: UnitNavMovement = unit.get_node("NavMovement")
		
		if nav._world_waypoints.is_empty():
			continue

		var points_to_draw: PackedVector2Array = PackedVector2Array()
		
		# Convert global coordinates to the Node2D's local space for accurate drawing.
		points_to_draw.append(to_local(unit.global_position))
		for i in range(nav._waypoint_index, nav._world_waypoints.size()):
			points_to_draw.append(to_local(nav._world_waypoints[i]))
			
		if points_to_draw.size() >= 2:
			draw_polyline(points_to_draw, Color.YELLOW, 2.0)
		for point in points_to_draw:
			draw_circle(point, 5.0, Color.RED)

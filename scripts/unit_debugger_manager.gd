extends Node2D
class_name UnitDebugManager

# Maintain a list of units we want to draw paths for.
# You can append to this when selecting units, or keep it tracking all units.
var active_units: Array[Node2D] = []
var _preview_path: PackedVector2Array = PackedVector2Array()

func set_preview_path(path: PackedVector2Array) -> void:
	_preview_path = path
	queue_redraw()

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
	_draw_active_units_paths()
	_draw_preview_path()

func _draw_active_units_paths() -> void:
	for unit in active_units:
		if not is_instance_valid(unit) or not unit.has_node("NavMovement"):
			continue
			  
		var nav: UnitNavMovement = unit.get_node("NavMovement")
		if nav._world_waypoints.is_empty():
			continue

		var world_points: PackedVector2Array = PackedVector2Array()
		world_points.append(unit.global_position)
		for i in range(nav._waypoint_index, nav._world_waypoints.size()):
			world_points.append(nav._world_waypoints[i])
			
		_draw_world_path(world_points, Color.YELLOW, Color.RED, 2.0, 5.0)

func _draw_preview_path() -> void:
	if _preview_path.size() >= 2:
		_draw_world_path(_preview_path, Color.CYAN, Color.CYAN, 3.0, 4.0)

func _draw_world_path(world_points: PackedVector2Array, line_color: Color, point_color: Color, line_width: float = 2.0, point_radius: float = 5.0) -> void:
	var local_points: PackedVector2Array = PackedVector2Array()
	# Convert global coordinates to the Node2D's local space for accurate drawing.
	for wp in world_points:
		local_points.append(to_local(wp))
		
	if local_points.size() >= 2:
		draw_polyline(local_points, line_color, line_width)
		
	for pt in local_points:
		draw_circle(pt, point_radius, point_color)

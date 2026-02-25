extends Camera2D
class_name RTSCamera

@export_group("Zoom")
@export var zoom_speed: float = 0.1
@export var zoom_min: Vector2 = Vector2(0.3, 0.3)
@export var zoom_max: Vector2 = Vector2(3.0, 3.0)

@export_group("Pan")
@export var edge_margin: float = 40.0
@export var edge_scroll_speed: float = 600.0

var _is_dragging: bool = false
var _drag_start_mouse_pos: Vector2 = Vector2.ZERO
var _target_zoom: Vector2 = zoom

func _ready() -> void:
	_target_zoom = zoom

func _unhandled_input(event: InputEvent) -> void:
	# --- Zoom ---
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_apply_zoom(1.0 + zoom_speed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_apply_zoom(1.0 - zoom_speed)
			
	# --- Middle Mouse Pan ---
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_MIDDLE:
		if event.is_pressed():
			_is_dragging = true
			_drag_start_mouse_pos = event.position
		else:
			_is_dragging = false
			
	if event is InputEventMouseMotion and _is_dragging:
		# Scale the translation by the current zoom level so panning speed feels consistent
		# In Godot 2D, smaller zoom numbers = zoomed out = world space is "bigger" per pixel
		global_position -= event.relative / zoom

func _process(delta: float) -> void:
	_process_edge_scroll(delta)

func _apply_zoom(factor: float) -> void:
	var _old_zoom: Vector2 = zoom
	_target_zoom = (_target_zoom * factor).clamp(zoom_min, zoom_max)
	
	# We want to zoom toward the mouse cursor
	var mouse_world_before := get_global_mouse_position()
	
	# Apply zoom immediately (for smoothing, consider a Tween in the future)
	zoom = _target_zoom
	
	# After zooming, the world point under the cursor has shifted
	var mouse_world_after := get_global_mouse_position()
	
	# Compensate by moving the camera to keep the cursor over the same world point
	global_position += (mouse_world_before - mouse_world_after)

func _process_edge_scroll(delta: float) -> void:
	var vp := get_viewport()
	if not is_instance_valid(vp):
		return
		
	var mouse_pos := vp.get_mouse_position()
	var vp_size := vp.get_visible_rect().size
	
	var scroll_dir := Vector2.ZERO
	
	# Check edges
	if mouse_pos.x < edge_margin:
		scroll_dir.x -= 1.0
	if mouse_pos.x > vp_size.x - edge_margin:
		scroll_dir.x += 1.0
	if mouse_pos.y < edge_margin:
		scroll_dir.y -= 1.0
	if mouse_pos.y > vp_size.y - edge_margin:
		scroll_dir.y += 1.0
		
	if scroll_dir != Vector2.ZERO:
		scroll_dir = scroll_dir.normalized()
		# Scale movement by zoom so scrolling covers roughly the same screen real-estate over time
		global_position += scroll_dir * edge_scroll_speed * delta / zoom.x

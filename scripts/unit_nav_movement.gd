extends Node2D
class_name UnitNavMovement
@onready var unit: Node2D = $".."
signal path_updated(unit: Node2D)
signal path_started(target_cell: Vector2i)
signal path_completed()
signal path_failed(reason: String)

enum State { IDLE, MOVING }
var _state: State = State.IDLE

var _pathfinder: HexPathfinder

@export var move_speed: float = 300.0
@export var arrival_distance: float = 2.0
@export var debug_draw: bool = false

var _current_path:Array[Vector2i] = []
var _world_waypoints: PackedVector2Array = PackedVector2Array()
var _waypoint_index: int = 0

func setup(pathfinder: HexPathfinder) -> void:
	_pathfinder = pathfinder
	if unit == null or _pathfinder == null:
		return

	var cell := _pathfinder.world_to_cell(unit.global_position)
	unit.global_position = _pathfinder.cell_to_world(cell)
	
func move_to_cell(target_cell: Vector2i) -> bool:
	var unit_cell: Vector2i = _pathfinder.world_to_cell(unit.global_position)
	if unit_cell == target_cell:
		path_completed.emit()
		return true
	if _state == State.MOVING:
		_world_waypoints.clear()
		_waypoint_index = 0
		
	if not _pathfinder.has_cell(unit_cell):
		path_failed.emit("start cell not in graph")
		return false
	if not _pathfinder.has_cell(target_cell):
		path_failed.emit("target cell not in group")
		return false
		
	_current_path = _pathfinder.get_cell_path(unit_cell, target_cell)
	if _current_path.is_empty():
		path_failed.emit("no path exists")
		return false
		
	_world_waypoints.clear()
	for i in range(1, _current_path.size()):
		_world_waypoints.append(_pathfinder.cell_to_world(_current_path[i]))
	_waypoint_index = 0
	_state = State.MOVING
	path_started.emit(target_cell)
	path_updated.emit(unit)
	return true
	
func move_to_world(target_world: Vector2) -> bool:
	return move_to_cell(_pathfinder.world_to_cell(target_world))

func _process(delta: float) -> void:
	if _state == State.IDLE:
		return

	if _waypoint_index >= _world_waypoints.size():
		_arrive()
		return

	var target: Vector2 = _world_waypoints[_waypoint_index]
	unit.global_position = unit.global_position.move_toward(target, move_speed * delta)
	
	if unit.global_position.distance_to(target) <= arrival_distance:
		unit.global_position = target
		_waypoint_index +=1
		path_updated.emit(unit)
		
func _arrive() -> void:
	_state = State.IDLE
	path_updated.emit(unit)
	path_completed.emit()
	_waypoint_index = 0
	_world_waypoints.clear()
	_current_path.clear()

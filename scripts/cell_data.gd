class_name CellData extends Resource

# Persistent logical coordinates (axial q,r) used by gameplay math.
@export var axial_coord: Vector2i
# Stable 1-based identifier (row-major in odd-r space) for external references.
@export var hex_id: int
# Gameplay/content classification for this cell (0 currently used as default grass).
@export var terrain_type: int = 0

# Runtime visual back-reference for convenience. Not serialized with map data.
var tile_ref: Node2D = null

func _to_string() -> String:
	return "CellData(id=%d, ax=%s, type=%d)" % [hex_id, axial_coord, terrain_type]

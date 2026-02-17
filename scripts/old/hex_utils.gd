class_name HexUtils

# Hex coordinate helpers for a pointy-top layout.
# This project stores grid logic in axial (q, r), but iterates/spawns by odd-r offset (col, row).
# All conversion helpers are centralized here so math assumptions stay consistent.

# Convert odd-r offset (col,row) to axial (q,r).
# Odd rows are visually shifted right by half a hex; parity is read with (row & 1).
static func offset_to_axial(col: int, row: int) -> Vector2i:
	var q := col - (row - (row & 1)) / 2
	var r := row
	return Vector2i(q, r)

# Convert axial (q,r) back to odd-r offset (col,row).
# Used when turning logical cell coordinates into world-space tile placement.
static func axial_to_offset(q: int, r: int) -> Vector2i:
	var col := q + (r - (r & 1)) / 2
	var row := r
	return Vector2i(col, row)

# Convert odd-r offset to world position.
# width: horizontal center-to-center spacing for pointy-top hexes.
# v_stride: vertical center-to-center spacing (3/4 of hex diameter).
# Odd rows get an extra half-width X shift to create the staggered layout.
static func offset_to_world(col: int, row: int, size: float, spacing: float = 0.0) -> Vector2:
	var width := sqrt(3.0) * size + spacing
	var v_stride := (2.0 * size) * 0.75 + spacing

	var x := width * col
	if row & 1:
		x += width * 0.5

	var y := v_stride * row
	return Vector2(x, y)

# Axial direction vectors (clockwise) for pointy-top hexes.
const AXIAL_DIRS: Array[Vector2i] = [
	Vector2i(+1,  0), Vector2i(+1, -1), Vector2i( 0, -1),
	Vector2i(-1,  0), Vector2i(-1, +1), Vector2i( 0, +1),
]

# Return six axial neighbor coordinates around a cell.
static func get_neighbors(axial: Vector2i) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for d in AXIAL_DIRS:
		out.append(axial + d)
	return out

# Hex distance using axial form of cube-distance formula.
static func hex_distance(a: Vector2i, b: Vector2i) -> int:
	var dq := a.x - b.x
	var dr := a.y - b.y
	return (absi(dq) + absi(dq + dr) + absi(dr)) / 2

# Stable sequential ID (1-based, row-major in offset space).
# This gives deterministic external references independent of object lifetimes.
static func id_from_offset(col: int, row: int, width: int) -> int:
	return row * width + col + 1

# Reverse mapping from stable ID back to odd-r offset coordinate.
static func offset_from_id(id: int, width: int) -> Vector2i:
	return Vector2i((id - 1) % width, (id - 1) / width)

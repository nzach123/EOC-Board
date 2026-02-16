class_name HexGrid extends Resource

# Logical hex grid model.
# Iteration/generation uses odd-r offset dimensions, but each cell is stored by axial coordinate.
# Dual indexing is maintained for fast lookup by either axial coord or stable integer ID.

# Grid dimensions in odd-r offset layout (columns x rows).
@export var width: int = 28
@export var height: int = 15

# Primary storage: axial coordinate -> CellData.
var _cells: Dictionary = {}

# Secondary lookup: stable hex ID -> CellData.
var _cells_by_id: Dictionary = {}

# Build a rectangular odd-r board and materialize each cell with deterministic axial + ID values.
func generate(w: int, h: int) -> void:
	width = w
	height = h
	_cells.clear()
	_cells_by_id.clear()
	
	for row in range(height):
		for col in range(width):
			var axial := HexUtils.offset_to_axial(col, row)
			var id := HexUtils.id_from_offset(col, row, width)
			
			var cell := CellData.new()
			cell.axial_coord = axial
			cell.hex_id = id
			cell.terrain_type = 0 # Default grass
			
			_cells[axial] = cell
			_cells_by_id[id] = cell

# Returns null if the axial coordinate is outside the generated board.
func get_cell(axial: Vector2i) -> CellData:
	return _cells.get(axial)

# Returns null for unknown IDs.
func get_cell_by_id(id: int) -> CellData:
	return _cells_by_id.get(id)

# Snapshot list of all cells. Order is dictionary-dependent and not guaranteed.
func get_all_cells() -> Array[CellData]:
	var result: Array[CellData] = []
	result.assign(_cells.values())
	return result

# Neighbor search is axial first, then filtered to cells that exist in this board.
func get_neighbors(axial: Vector2i) -> Array[CellData]:
	var neighbor_coords := HexUtils.get_neighbors(axial)
	var neighbor_cells: Array[CellData] = []
	for nc in neighbor_coords:
		if _cells.has(nc):
			neighbor_cells.append(_cells[nc])
	return neighbor_cells

# Returns -1 when either endpoint is invalid.
func hex_distance(a: CellData, b: CellData) -> int:
	if not a or not b: return -1
	return HexUtils.hex_distance(a.axial_coord, b.axial_coord)

# Serialize only persistent logical data.
# Visual runtime references (like tile nodes) are intentionally excluded.
func to_dict() -> Dictionary:
	var data := {
		"width": width,
		"height": height,
		"cells": []
	}
	
	for key in _cells:
		var cell: CellData = _cells[key]
		data["cells"].append({
			"q": cell.axial_coord.x,
			"r": cell.axial_coord.y,
			"id": cell.hex_id,
			"type": cell.terrain_type
		})
	return data

# Rebuild grid state from serialized map data.
# Missing values fall back to current defaults for compatibility.
func from_dict(data: Dictionary) -> void:
	width = data.get("width", 28)
	height = data.get("height", 15)
	_cells.clear()
	_cells_by_id.clear()
	
	var cell_list = data.get("cells", [])
	for c_data in cell_list:
		var q = c_data.get("q")
		var r = c_data.get("r")
		var id = c_data.get("id")
		var type = c_data.get("type", 0)
		
		var axial = Vector2i(q, r)
		var cell = CellData.new()
		cell.axial_coord = axial
		cell.hex_id = id
		cell.terrain_type = type
		
		_cells[axial] = cell
		_cells_by_id[id] = cell

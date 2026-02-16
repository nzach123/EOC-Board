extends "res://addons/gut/test.gd"

const HexUtils = preload("res://scripts/hex_utils.gd")
const HexGrid = preload("res://scripts/hex_grid.gd")
const CellData = preload("res://scripts/cell_data.gd")

var grid: HexGrid

func before_each():
	grid = HexGrid.new()

func test_generate():
	grid.generate(28, 15)
	# 28 * 15 = 420
	assert_eq(grid.get_all_cells().size(), 420, "Should define 420 cells")
	
	# Check first cell (0,0 offset) -> (0,0 axial) -> ID 1
	var c1 = grid.get_cell_by_id(1)
	assert_not_null(c1, "Cell ID 1 should exist")
	assert_eq(c1.axial_coord, Vector2i(0,0), "ID 1 should be at (0,0)")
	
	# Check last cell (27, 14 offset) -> ID 420
	var cLast = grid.get_cell_by_id(420)
	assert_not_null(cLast, "Cell ID 420 should exist")
	# Offset (27, 14) -> Axial?
	# Axial q = col - (row - (row&1))/2 = 27 - (14 - 0)/2 = 27 - 7 = 20.
	# r = 14.
	# So (20, 14).
	assert_eq(cLast.axial_coord, Vector2i(20, 14), "ID 420 check")

func test_neighbors_on_grid():
	grid.generate(5, 5) # Smaller grid for test
	# (0,0) offset -> (0,0) axial. Corner. Defines 2 neighbors?
	# Neighbors of (0,0) axial are: (1,0), (1,-1), (0,-1), (-1,0), (-1,1), (0,1)
	# On a 5x5 grid (Odd-r):
	# (0,0) exists.
	# (1,0) offset -> (1,0) axial. EXISTS.
	# (0,1) offset -> (0,1) axial. EXISTS.
	# (-1, 0) offset -> out of bounds.
	# (0, -1) offset -> out of bounds.
	# (1, -1) offset -> out of bounds.
	# (-1, 1) offset -> out of bounds.
	
	# So (0,0) should have 2 neighbors on grid: (1,0) and (0,1).
	var c00 = grid.get_cell(Vector2i(0,0))
	var n = grid.get_neighbors(c00.axial_coord)
	
	assert_eq(n.size(), 2, "Corner (0,0) should have 2 neighbors")
	
	# Middle cell (2,2) offset -> q = 2 - (2-0)/2 = 1. r=2. -> (1,2) axial.
	# Should have 6 neighbors if far from edge.
	var cMid = grid.get_cell(Vector2i(1,2))
	var nMid = grid.get_neighbors(cMid.axial_coord)
	# Check boundaries. 5x5 grid.
	# (2,2) has neighbors (all 6 fit in 5x5?)
	# Let's see:
	# (3,2) offset -> (2,2) axial. Exists.
	# (1,2) offset -> (0,2) axial. Exists.
	# (2,1) offset -> (2,1) axial. Exists.
	# (3,1) offset -> (3,1) axial. Exists.
	# (2,3) offset -> (1,3) axial. Exists.
	# (3,3) offset -> (2,3) axial. Exists.
	
	assert_eq(nMid.size(), 6, "Middle cell should have 6 neighbors")

func test_serialization():
	grid.generate(3, 3) 
	var c = grid.get_cell_by_id(1)
	c.terrain_type = 5 # Set custom type
	
	var data = grid.to_dict()
	
	var new_grid = HexGrid.new()
	new_grid.from_dict(data)
	
	assert_eq(new_grid.width, 3)
	assert_eq(new_grid.height, 3)
	var c_new = new_grid.get_cell_by_id(1)
	assert_eq(c_new.terrain_type, 5, "Terrain type preserved")

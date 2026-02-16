extends "res://addons/gut/test.gd"

const HexUtils = preload("res://scripts/hex_utils.gd")

func test_offset_to_axial_and_back():
	# Test known conversions for Odd-r
	# (0,0) -> (0,0)
	var q0 = HexUtils.offset_to_axial(0, 0)
	assert_eq(q0, Vector2i(0, 0), "(0,0) offset should be (0,0) axial")
	assert_eq(HexUtils.axial_to_offset(0, 0), Vector2i(0, 0), "Reverse (0,0) check")

	# (1,0) -> (1,0)
	assert_eq(HexUtils.offset_to_axial(1, 0), Vector2i(1, 0))
	
	# (0,1) -> (0 - (1 - 1)/2, 1) = (0, 1) -> Wait. math: 0 - (1 - 1)/2 = 0.
	# Odd-r offset to axial formula: q = col - (row - (row&1)) / 2
	# row=1 (odd). (row&1)=1. row-(row&1) = 0. 0/2 = 0. q = col.
	# So (0,1) -> (0, 1).
	assert_eq(HexUtils.offset_to_axial(0, 1), Vector2i(0, 1), "Offset (0,1) -> Axial (0,1)")
	
	# (1,1) -> (1, 1)
	assert_eq(HexUtils.offset_to_axial(1, 1), Vector2i(1, 1), "Offset (1,1) -> Axial (1,1)")
	
	# (0,2) -> row=2 (even). (row&1)=0. row-(row&1)=2. 2/2=1. q = col - 1.
	# So (0,2) -> (-1, 2).
	assert_eq(HexUtils.offset_to_axial(0, 2), Vector2i(-1, 2), "Offset (0,2) -> Axial (-1, 2)")
	assert_eq(HexUtils.axial_to_offset(-1, 2), Vector2i(0, 2), "Reverse (-1, 2) check")

func test_neighbors():
	# (0,0) neighbors
	var n = HexUtils.get_neighbors(Vector2i(0,0))
	assert_eq(n.size(), 6, "Should have 6 neighbors")
	assert_has(n, Vector2i(1, 0), "Right neighbor")
	assert_has(n, Vector2i(1, -1), "Top-right neighbor")

func test_distance():
	assert_eq(HexUtils.hex_distance(Vector2i(0,0), Vector2i(0,0)), 0)
	assert_eq(HexUtils.hex_distance(Vector2i(0,0), Vector2i(1,0)), 1)
	assert_eq(HexUtils.hex_distance(Vector2i(0,0), Vector2i(2,0)), 2)
	assert_eq(HexUtils.hex_distance(Vector2i(0,0), Vector2i(0,2)), 2)

func test_id_mapping():
	# Width 28
	var w = 28
	# (0,0) -> ID 1
	assert_eq(HexUtils.id_from_offset(0, 0, w), 1)
	assert_eq(HexUtils.offset_from_id(1, w), Vector2i(0,0))
	
	# (27, 0) -> ID 28
	assert_eq(HexUtils.id_from_offset(27, 0, w), 28)
	
	# (0, 1) -> ID 29
	assert_eq(HexUtils.id_from_offset(0, 1, w), 29)

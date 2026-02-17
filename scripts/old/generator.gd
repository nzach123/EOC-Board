extends Node2D

# Procedural hex board spawner (legacy runtime path).
# This script builds a centered axial-coordinate board by instancing one Tile per (q,r) pair,
# then computes direct neighbor links between spawned tiles.

@export var tile_scene: PackedScene = preload("uid://w0ewblpju7pv")

@export var rows: int = 3
@export var coloumns: int = 3
@export var spacing: int = 10

# Hex geometry basis:
# outer_radius: center -> point (vertex)
# inner_radius: center -> edge midpoint (apothem) for pointy/flat transform usage
var outer_radius = 64
var inner_radius = outer_radius * sqrt(3) / 2

# Axial coordinate (Vector2 q,r) -> Tile instance.
var datamap: Dictionary = {}

func _ready() -> void:
	# Creates a symmetric axial range from -N..+N for both coordinates.
	for row in range(-rows, rows + 1):
		for coloumn in range(-coloumns, coloumns + 1):
			create_cell(row,coloumn)
	
	print(datamap)

func create_cell(x: int, y: int):
	var tile : Tile = tile_scene.instantiate()
	
	var tile_pos: Vector2
	# Flat-top projection from axial-ish coordinates.
	#tile_pos.x = (outer_radius + spacing) * 1.5 * (x-y)
	#tile_pos.y = (inner_radius + spacing) * (x+y)
	# Pointy-top alternative (kept for quick switch/testing):
	tile_pos.x = (inner_radius + spacing) * (x+y)
	tile_pos.y = (outer_radius + spacing) * 1.5 * (x-y)
	tile.global_position = tile_pos
	tile.pos = Vector2(x,y)
	
	add_child(tile)
	datamap[Vector2(x,y)] = tile
	tile.update()
	generate_neighbor()
	return

func generate_neighbor():
	# For each tile, probe all six hex directions and link existing adjacent tiles.
	for value in datamap:
		var center_v = value
		var c_tile: Tile = datamap[value]
		var test_v: Vector2
		
		for v_key in CS.Vdict.keys():
			test_v = center_v + CS.Vdict[v_key]
			if datamap.has(test_v): 
				c_tile.Neighbors[v_key] = datamap[test_v]
		c_tile.update_neighbors()
	

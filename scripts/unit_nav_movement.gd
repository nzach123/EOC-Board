extends Node
class_name UnitNavMovement

var astar_grid = AStarGrid2D

func initialize_grid(tilemap: TileMapLayer) -> void:
	astar_grid = AStarGrid2D.new()
	astar_grid.region=tilemap.get_used_rect()
	astar_grid.DiagonalMode=astar_grid.DIAGONAL_MODE_NEVER
	astar_grid.update()
	
	var region = astar_grid.region
	
	for x in range(region.position.x, region.end.x):
		for y in range(region.position.y, region.end.y):
			var cell = Vector2i(x,y)
			
			var source_id = tilemap.get_cell_source_id(cell)
			
			if source_id == -1:
				astar_grid.set_point_solid(cell,true)
			else:
				astar_grid.set_point_solid(cell, true)
			
				

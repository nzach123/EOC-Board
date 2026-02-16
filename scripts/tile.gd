extends Sprite2D
class_name Tile

var pos: Vector2

# Neighbors 
var q : Tile
var qn : Tile
var r : Tile
var rn : Tile
var s : Tile
var sn : Tile

var Neighbors = {
	"q": q,
	"r": r,
	"s": s,
	"qn": qn,
	"rn": rn,
	"sn": sn,
}

func update():
	$CoordsLabel.text = "{x}, {y}".format({"x": int(pos.x),"y": int(pos.y)})
	return
	
func update_neighbors():
	q = Neighbors["q"]
	r = Neighbors["r"]
	s = Neighbors["s"]
	qn = Neighbors["qn"]
	rn = Neighbors["rn"]
	sn = Neighbors["sn"]

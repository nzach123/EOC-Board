extends Sprite2D
class_name Tile

# Axial-ish coordinate assigned by generator (q,r packed in Vector2).
var pos: Vector2

# Direct references to adjacent tiles in each hex direction.
var q : Tile
var qn : Tile
var r : Tile
var rn : Tile
var s : Tile
var sn : Tile

# Direction-keyed neighbor cache filled by generator.gd::generate_neighbor().
var Neighbors = {
	"q": q,
	"r": r,
	"s": s,
	"qn": qn,
	"rn": rn,
	"sn": sn,
}

func update():
	# Displays this tile's assigned axial coordinate for debugging/layout validation.
	$CoordsLabel.text = "{x}, {y}".format({"x": int(pos.x),"y": int(pos.y)})
	return

func update_neighbors():
	# Materialize typed neighbor refs from dictionary entries for quicker direct access.
	q = Neighbors["q"]
	r = Neighbors["r"]
	s = Neighbors["s"]
	qn = Neighbors["qn"]
	rn = Neighbors["rn"]
	sn = Neighbors["sn"]

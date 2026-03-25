extends Node2D

@export var path: Path2D

func _ready():
	path.track_built.connect(queue_redraw)
	queue_redraw()

func _draw():
	if not path or not path.curve:
		return
	var points = path.curve.get_baked_points()
	for i in range(points.size() - 1):
		draw_line(points[i], points[i+1], Color.WHITE, 3.0)

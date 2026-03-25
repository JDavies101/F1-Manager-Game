extends Node2D

@export var path: Path2D

var car_positions: Array = []

func _ready():
	path.track_built.connect(_on_track_built)

func _on_track_built():
	queue_redraw()

func _draw():
	if not path or not path.curve:
		return
	var points = path.curve.get_baked_points()
	if points.size() == 0:
		return
	
	for i in range(points.size() - 1):
		draw_line(points[i], points[i+1], Color.WHITE, 3.0)
	
	for car in car_positions:
		var t = fmod(car.progress, 1.0)
		var pos = path.curve.sample_baked(t * path.curve.get_baked_length())
		var color = Color(car.color_r, car.color_g, car.color_b)
		draw_circle(pos, 6.0, color)
		draw_circle(pos, 6.0, Color.BLACK)
		draw_circle(pos, 5.0, color)

func update_cars(positions: Array):
	car_positions = positions
	queue_redraw()

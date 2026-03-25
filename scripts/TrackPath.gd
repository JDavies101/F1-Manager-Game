extends Path2D

signal track_built

func _ready():
	curve = Curve2D.new()
	await get_tree().process_frame
	_build_melbourne()
	track_built.emit()

func _build_melbourne():
	var vp_size = get_viewport().get_visible_rect().size
	var cx = vp_size.x * 0.45
	var cy = vp_size.y * 0.5
	var rx = vp_size.x * 0.35
	var ry = vp_size.y * 0.4
	
	var point_ratios = [
		Vector2(0.5, 0.1), Vector2(0.65, 0.07), Vector2(0.78, 0.12),
		Vector2(0.87, 0.22), Vector2(0.9, 0.38), Vector2(0.85, 0.55),
		Vector2(0.75, 0.68), Vector2(0.62, 0.76), Vector2(0.5, 0.79),
		Vector2(0.37, 0.76), Vector2(0.24, 0.68), Vector2(0.14, 0.55),
		Vector2(0.1, 0.38), Vector2(0.13, 0.22), Vector2(0.24, 0.12),
		Vector2(0.38, 0.08), Vector2(0.46, 0.07)
	]
	
	for r in point_ratios:
		curve.add_point(Vector2(vp_size.x * r.x, vp_size.y * r.y))
	curve.add_point(Vector2(vp_size.x * point_ratios[0].x, vp_size.y * point_ratios[0].y))

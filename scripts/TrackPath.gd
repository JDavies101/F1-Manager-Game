extends Path2D

signal track_built

func _ready():
	curve = Curve2D.new()
	await get_tree().process_frame
	_build_melbourne()
	track_built.emit()

func _build_melbourne():
	var vp = get_viewport().get_visible_rect().size
	var w = vp.x
	var h = vp.y
	var pad = 0.1

	var pts = [
		Vector2(0.3452, 0.1319), Vector2(0.3808, 0.1874),
		Vector2(0.3847, 0.1982), Vector2(0.3828, 0.2085),
		Vector2(0.3679, 0.2414), Vector2(0.3669, 0.2604),
		Vector2(0.3672, 0.2716), Vector2(0.3790, 0.3257),
		Vector2(0.4170, 0.4466), Vector2(0.4386, 0.4929),
		Vector2(0.4686, 0.5346), Vector2(0.4808, 0.5465),
		Vector2(0.5188, 0.5740), Vector2(0.5515, 0.5850),
		Vector2(0.5984, 0.5937), Vector2(0.6192, 0.5956),
		Vector2(0.6388, 0.5974), Vector2(0.6469, 0.5927),
		Vector2(0.6543, 0.5781), Vector2(0.6732, 0.5494),
		Vector2(0.6853, 0.5317), Vector2(0.6926, 0.5269),
		Vector2(0.7086, 0.5295), Vector2(0.8132, 0.5460),
		Vector2(0.8496, 0.5625), Vector2(0.8815, 0.5951),
		Vector2(0.9857, 0.7293), Vector2(1.0000, 0.7533),
		Vector2(0.9989, 0.7617), Vector2(0.9488, 0.8896),
		Vector2(0.9316, 0.9290), Vector2(0.9139, 0.9418),
		Vector2(0.8986, 0.9391), Vector2(0.8080, 0.8699),
		Vector2(0.8008, 0.8690), Vector2(0.7947, 0.8791),
		Vector2(0.7933, 0.9120), Vector2(0.7897, 0.9634),
		Vector2(0.7863, 0.9753), Vector2(0.7764, 0.9885),
		Vector2(0.7697, 0.9977), Vector2(0.7583, 1.0000),
		Vector2(0.7240, 0.9936), Vector2(0.6383, 0.9693),
		Vector2(0.4414, 0.9120), Vector2(0.3524, 0.8859),
		Vector2(0.3421, 0.8795), Vector2(0.3385, 0.8502),
		Vector2(0.3330, 0.8172), Vector2(0.3138, 0.7870),
		Vector2(0.2939, 0.7737), Vector2(0.2800, 0.7700),
		Vector2(0.2442, 0.7636), Vector2(0.1638, 0.7361),
		Vector2(0.1486, 0.7293), Vector2(0.0854, 0.6903),
		Vector2(0.0646, 0.6757), Vector2(0.0277, 0.6445),
		Vector2(0.0213, 0.6303), Vector2(0.0232, 0.6161),
		Vector2(0.0307, 0.5987), Vector2(0.0426, 0.5712),
		Vector2(0.0487, 0.5350), Vector2(0.0482, 0.5007),
		Vector2(0.0396, 0.4727), Vector2(0.0196, 0.4288),
		Vector2(0.0041, 0.3953), Vector2(0.0000, 0.3835),
		Vector2(0.0002, 0.3601), Vector2(0.0199, 0.2547),
		Vector2(0.0368, 0.2057), Vector2(0.0648, 0.1411),
		Vector2(0.0872, 0.0590), Vector2(0.0970, 0.0467),
		Vector2(0.1142, 0.0495), Vector2(0.1342, 0.0472),
		Vector2(0.1550, 0.0357), Vector2(0.1832, 0.0096),
		Vector2(0.2068, 0.0014), Vector2(0.2298, 0.0000),
		Vector2(0.2512, 0.0064), Vector2(0.2703, 0.0202),
		Vector2(0.3066, 0.0683), Vector2(0.3452, 0.1319),
	]

	for p in pts:
		var x = pad * w + p.x * w * (1.0 - pad * 2.0)
		var y = pad * h + p.y * h * (1.0 - pad * 2.0)
		curve.add_point(Vector2(x, y))

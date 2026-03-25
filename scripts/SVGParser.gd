class_name SVGParser

static func parse_path(d: String, scale: Vector2, offset: Vector2) -> Array:
	var points = []
	var tokens = _tokenize(d)
	print("Token count: ", tokens.size())
	var i = 0
	var cx = 0.0
	var cy = 0.0
	var cmd = ""

	while i < tokens.size():
		var t = tokens[i]
		
		# check if token is a command letter
		if t.length() == 1 and not t.is_valid_float():
			cmd = t
			i += 1
			continue

		match cmd:
			"M":
				cx = float(tokens[i]); cy = float(tokens[i+1])
				points.append(Vector2(cx * scale.x + offset.x, cy * scale.y + offset.y))
				i += 2
			"m":
				cx += float(tokens[i]); cy += float(tokens[i+1])
				points.append(Vector2(cx * scale.x + offset.x, cy * scale.y + offset.y))
				i += 2
			"L":
				cx = float(tokens[i]); cy = float(tokens[i+1])
				points.append(Vector2(cx * scale.x + offset.x, cy * scale.y + offset.y))
				i += 2
			"l":
				cx += float(tokens[i]); cy += float(tokens[i+1])
				points.append(Vector2(cx * scale.x + offset.x, cy * scale.y + offset.y))
				i += 2
			"C":
				cx = float(tokens[i+4]); cy = float(tokens[i+5])
				points.append(Vector2(cx * scale.x + offset.x, cy * scale.y + offset.y))
				i += 6
			"c":
				cx += float(tokens[i+4]); cy += float(tokens[i+5])
				points.append(Vector2(cx * scale.x + offset.x, cy * scale.y + offset.y))
				i += 6
			"z", "Z":
				i += 1
			_:
				print("unknown cmd: ", cmd, " token: ", t)
				i += 1

	print("Points parsed: ", points.size())
	return points

static func _tokenize(d: String) -> Array:
	var result = []
	var current = ""
	
	for c in d:
		if c.to_upper() != c.to_lower():
			# it's a letter
			if current != "":
				result.append(current)
				current = ""
			result.append(c)
		elif c == " " or c == "\n" or c == "\t" or c == ",":
			if current != "":
				result.append(current)
				current = ""
		elif c == "-" and current != "" and current[-1] != "e":
			result.append(current)
			current = "-"
		else:
			current += c
	
	if current != "":
		result.append(current)
	
	return result

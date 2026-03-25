extends Control

@onready var timing_list = $HBoxContainer/VBoxContainer/ScrollContainer/TimingList
@onready var tyre_info = $HBoxContainer/VBoxContainer2/TyreInfo
@onready var tyre_age = $HBoxContainer/VBoxContainer2/TyreAge
@onready var gap_info = $HBoxContainer/VBoxContainer2/GapInfo
@onready var lap_counter = $HBoxContainer/VBoxContainer2/LapCounter
@onready var track_draw = $HBoxContainer/SubViewportContainer/SubViewport/TrackView/Node2D
@onready var fuel_info = $HBoxContainer/VBoxContainer2/FuelInfo
@onready var track_temp_label = $HBoxContainer/VBoxContainer2/TrackTemp
@onready var conditions_label = $HBoxContainer/VBoxContainer2/Conditions

var current_lap: int = 0
var total_laps: int = 0
var player_tyre: String = "Medium"
var player_tyre_age: int = 0
var positions: Array = []
var timer: Timer

func _ready():
	await get_tree().process_frame
	$HBoxContainer/SubViewportContainer/SubViewport.size = $HBoxContainer/SubViewportContainer.size
	$HBoxContainer/VBoxContainer/ScrollContainer.custom_minimum_size = Vector2(0, 300)
	total_laps = GameState.selected_race.lap_count
	_init_positions()
	_update_ui()
	_setup_timer()

func _init_positions():
	positions = []
	for d in GameState.drivers:
		positions.append({
			"name": d.name,
			"team": d.team,
			"gap": randf_range(0.0, 5.0),
			"tyre": "Medium",
			"tyre_age": 0,
			"pace": d.pace,
			"is_player": d.team == GameState.team_name,
			"total_time": randf_range(0.0, 2.0),  # stagger start
		})
	positions.shuffle()
	
func _setup_timer():
	timer = Timer.new()
	timer.wait_time = 1.0
	timer.timeout.connect(_on_lap_tick)
	add_child(timer)
	timer.start()
	
func _on_lap_tick():
	if current_lap >= total_laps:
		timer.stop()
		return
	current_lap += 1
	player_tyre_age += 1
	_simulate_lap()
	_update_ui()
	
func _simulate_lap():
	var track = GameState.track_data.get(GameState.selected_race.circuit)
	var deg_mod = track.tyre_deg_modifier if track else 1.0
	var base_lap = track.base_lap_time if track else 90.0

	# Temperature effect on deg — higher track temp = more deg
	var temp_mod = 1.0 + (GameState.track_temp - 35.0) * 0.01

	# Sort by gap to find car ahead
	var sorted = positions.duplicate()
	sorted.sort_custom(func(a, b): return a.total_time < b.total_time)

	for idx in sorted.size():
		var p = sorted[idx]
		var tyre = GameState.tyres.get(p.tyre)
		if not tyre:
			continue

		# Base pace from driver rating
		var pace_delta = (100.0 - p.pace) * 0.05

		# Fuel
		var fuel_remaining = max(Data.FuelModel.FUEL_LOAD_KG - (current_lap * Data.FuelModel.FUEL_BURN_PER_LAP), 0.0)
		var fuel_delta = fuel_remaining * 0.003

		# Compound base
		var compound_delta = tyre.base_lap_time_delta

		# Warmup
		var warmup_delta = 0.0
		if p.tyre_age < tyre.warmup_laps:
			warmup_delta = (tyre.warmup_laps - p.tyre_age) * 0.5

		# Deg with track + temp modifier
		var effective_deg = tyre.deg_rate * deg_mod * temp_mod
		var deg_delta = 0.0
		if p.tyre_age >= tyre.cliff_lap:
			deg_delta = effective_deg * p.tyre_age * 3.0
		else:
			deg_delta = effective_deg * p.tyre_age

		## Traffic — based on track position fraction, not time
		var traffic_delta = 0.0
		if idx > 0:
			var car_ahead = sorted[idx - 1]
			var my_progress = fmod(float(current_lap) / float(total_laps), 1.0)
			var ahead_progress = fmod(float(current_lap) / float(total_laps) - float(idx) * 0.015, 1.0)
			var gap_fraction = float(idx) * 0.015
			if gap_fraction < 0.02:
				var track_obj = GameState.track_data.get(GameState.selected_race.circuit)
				var overtake_diff = track_obj.overtake_difficulty if track_obj else 0.6
				traffic_delta = (1.0 - gap_fraction / 0.02) * 0.8 * overtake_diff
		
		# Wet conditions
		var wet_delta = 0.0
		if GameState.is_wet:
			wet_delta = randf_range(2.0, 5.0)

		var variation = randf_range(-0.08, 0.08)

		var lap_time = base_lap + pace_delta + compound_delta + warmup_delta + deg_delta + fuel_delta + traffic_delta + wet_delta + variation
		p.total_time += lap_time
		p.tyre_age += 1

	_update_track_positions()

func _update_track_positions():
	var sorted = positions.duplicate()
	sorted.sort_custom(func(a, b): return a.total_time < b.total_time)
	
	var leader_gap = sorted[0].total_time
	var last_gap = sorted[-1].total_time
	var gap_range = max(last_gap - leader_gap, 1.0)
	
	var lap_progress = fmod(float(current_lap) / 3.0, 1.0) 	
	var car_data = []
	for p in sorted:
		var gap_offset = (p.total_time - leader_gap) / gap_range * 0.15
		var progress = fmod(lap_progress - gap_offset + 1.0, 1.0)
		var team_color = _get_team_color(p.team)
		car_data.append({
			"progress": progress,
			"color_r": team_color.r,
			"color_g": team_color.g,
			"color_b": team_color.b
		})
	
	track_draw.update_cars(car_data)

func _get_team_color(team: String) -> Color:
	var colors = {
		"RedBull": Color(0.0, 0.0, 0.6),
		"McLaren": Color(1.0, 0.5, 0.0),
		"Ferrari": Color(1.0, 0.0, 0.0),
		"Mercedes": Color(0.0, 0.8, 0.7),
		"Williams": Color(0.0, 0.4, 1.0),
		"AstonMartin": Color(0.0, 0.5, 0.3),
		"Alpine": Color(0.0, 0.2, 1.0),
		"Haas": Color(0.8, 0.8, 0.8),
		"RacingBulls": Color(0.3, 0.5, 1.0),
		"Cadillac": Color(0.9, 0.1, 0.1),
		"Audi": Color(0.85, 0.0, 0.0),
	}
	return colors.get(team, Color.WHITE)

func _update_ui():
	lap_counter.text = "Lap %d / %d" % [current_lap, total_laps]
	tyre_info.text = "Tyre: %s" % player_tyre
	tyre_age.text = "Age: %d laps" % player_tyre_age
	
	for child in timing_list.get_children():
		child.queue_free()
	
	var sorted = positions.duplicate()
	sorted.sort_custom(func(a, b): return a.total_time < b.total_time)
	var leader_time = sorted[0].total_time
	var player_gap_val = 0.0

	for i in sorted.size():
		var p = sorted[i]
		var gap_to_leader = p.total_time - leader_time
		var gap_str = "Leader" if i == 0 else "+%.2fs" % gap_to_leader
		if p.is_player:
			player_gap_val = gap_to_leader
		var lbl = Label.new()
		lbl.text = "%d. %s  %s" % [i + 1, p.name, gap_str]
		timing_list.add_child(lbl)
		
	gap_info.text = "Gap: +%.2fs" % player_gap_val if player_gap_val > 0 else "Gap: Leader"
	
	var fuel = Data.FuelModel.FUEL_LOAD_KG - (current_lap * Data.FuelModel.FUEL_BURN_PER_LAP)
	fuel_info.text = "Fuel: %.1fkg" % max(fuel, 0.0)
	track_temp_label.text = "Track: %.0f°C" % GameState.track_temp
	conditions_label.text = "Wet" if GameState.is_wet else "Dry"
		
func _on_soft_pressed():
	_pit_stop("Soft")
	
func _on_medium_pressed():
	_pit_stop("Medium")
	
func _on_hard_pressed():
	_pit_stop("hard")
	
func _pit_stop(compound: String):
	player_tyre = compound
	player_tyre_age = 0
	tyre_info.text = "Tyre: %s" % player_tyre
	tyre_age.text = "Age: 0 laps"
	
func _on_back_pressed():
	timer.stop()
	get_tree().change_scene_to_file("res://scenes/ui/TeamHub.tscn")

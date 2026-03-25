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

var current_lap: int = 1
var total_laps: int = 0
var player_tyre: String = "Medium"
var player_tyre_age: int = 0
var positions: Array = []
var sim_speed: int = 5
var lap_timer: float = 0.0
var lap_duration: float = 18.0
var car_progress: Array = []
var gap_update_timer: float = 0.0
var track_ref = null
var lap_time_ref: float = 90.0

const START_FINISH_OFFSET = 0.55

func _ready():
	await get_tree().process_frame
	$HBoxContainer/SubViewportContainer/SubViewport.size = $HBoxContainer/SubViewportContainer.size
	$HBoxContainer/VBoxContainer/ScrollContainer.custom_minimum_size = Vector2(0, 300)

	track_ref = GameState.track_data.get(GameState.selected_race.circuit)
	lap_time_ref = track_ref.base_lap_time if track_ref else 90.0
	total_laps = GameState.selected_race.lap_count
	lap_duration = lap_time_ref / sim_speed

	_init_positions()
	_simulate_lap()
	_update_track_positions()
	_update_ui()

func _process(delta: float):
	if current_lap > total_laps:
		return

	lap_timer += delta
	gap_update_timer += delta

	_update_track_positions()

	if gap_update_timer >= 1.0:
		gap_update_timer = 0.0
		_update_timing_tower()

	if lap_timer >= lap_duration:
		lap_timer = 0.0
		current_lap += 1
		player_tyre_age += 1
		_simulate_lap()
		_update_ui()

func _init_positions():
	positions = []
	for d in GameState.drivers:
		positions.append({
			"name": d.name,
			"team": d.team,
			"tyre": "Medium",
			"tyre_age": 0,
			"pace": d.pace,
			"is_player": d.team == GameState.team_name,
			"total_time": randf_range(0.0, 0.5),
			"lap_count": 0,
			"prev_progress": START_FINISH_OFFSET,
		})
	positions.shuffle()

func _simulate_lap():
	var deg_mod = track_ref.tyre_deg_modifier if track_ref else 1.0
	var base_lap = lap_time_ref
	var temp_mod = 1.0 + (GameState.track_temp - 35.0) * 0.01

	var sim_sorted = positions.duplicate()
	sim_sorted.sort_custom(func(a, b): return a.total_time < b.total_time)

	for idx in sim_sorted.size():
		var p = sim_sorted[idx]
		var tyre = GameState.tyres.get(p.tyre)
		if not tyre:
			continue

		var pace_delta = (100.0 - p.pace) * 0.05
		var fuel_remaining = max(Data.FuelModel.FUEL_LOAD_KG - (current_lap * Data.FuelModel.FUEL_BURN_PER_LAP), 0.0)
		var fuel_delta = fuel_remaining * 0.003
		var compound_delta = tyre.base_lap_time_delta

		var warmup_delta = 0.0
		if p.tyre_age < tyre.warmup_laps:
			warmup_delta = (tyre.warmup_laps - p.tyre_age) * 0.5

		var effective_deg = tyre.deg_rate * deg_mod * temp_mod
		var deg_delta = 0.0
		if p.tyre_age >= tyre.cliff_lap:
			deg_delta = effective_deg * p.tyre_age * 3.0
		else:
			deg_delta = effective_deg * p.tyre_age

		var traffic_delta = 0.0
		if idx > 0:
			var gap_fraction = float(idx) * 0.015
			if gap_fraction < 0.02:
				var overtake_diff = track_ref.overtake_difficulty if track_ref else 0.6
				traffic_delta = (1.0 - gap_fraction / 0.02) * 0.8 * overtake_diff

		var wet_delta = 0.0
		if GameState.is_wet:
			wet_delta = randf_range(2.0, 5.0)

		var variation = randf_range(-0.08, 0.08)
		var lap_time = base_lap + pace_delta + compound_delta + warmup_delta + deg_delta + fuel_delta + traffic_delta + wet_delta + variation

		for orig in positions:
			if orig.name == p.name:
				orig.total_time += lap_time
				orig.tyre_age += 1
				break

func _update_track_positions():
	var lap_fraction = lap_timer / lap_duration
	
	# Find leader's total time for reference
	var time_sorted = positions.duplicate()
	time_sorted.sort_custom(func(a, b): return a.total_time < b.total_time)
	var leader_time = time_sorted[0].total_time
	
	car_progress = []
	for p in positions:
		# Convert time gap to track position gap
		# Each second behind = fraction of a lap behind
		var time_gap = p.total_time - leader_time
		var position_gap = max(time_gap / lap_time_ref, 0.0)
		var progress = fmod(lap_fraction + START_FINISH_OFFSET - position_gap + 100.0, 1.0)
		var team_color = _get_team_color(p.team)
		car_progress.append({
			"name": p.name,
			"progress": progress,
			"color_r": team_color.r,
			"color_g": team_color.g,
			"color_b": team_color.b
		})
	
	track_draw.update_cars(car_progress)

func _update_timing_tower():
	for child in timing_list.get_children():
		child.queue_free()
	if positions.size() == 0:
		return

	var time_sorted = positions.duplicate()
	time_sorted.sort_custom(func(a, b): return a.total_time < b.total_time)

	var lap_fraction = lap_timer / lap_duration
	var leader_pace = (100.0 - time_sorted[0].pace) * 0.05
	var leader_estimated = time_sorted[0].total_time + lap_fraction * (lap_time_ref + leader_pace)
	var player_gap_val = 0.0

	for rank in time_sorted.size():
		var p = time_sorted[rank]
		var pace_delta = (100.0 - p.pace) * 0.05
		var estimated_time = p.total_time + lap_fraction * (lap_time_ref + pace_delta)
		var gap_seconds = estimated_time - leader_estimated
		var gap_str = "Leader" if rank == 0 else "+%.2fs" % gap_seconds
		if p.is_player:
			player_gap_val = gap_seconds
		var lbl = Label.new()
		lbl.text = "%d. %s  %s" % [rank + 1, p.name, gap_str]
		timing_list.add_child(lbl)

	gap_info.text = "Gap: +%.2fs" % player_gap_val if player_gap_val > 0 else "Gap: Leader"
	
func _update_ui():
	lap_counter.text = "Lap %d / %d" % [current_lap, total_laps]
	tyre_info.text = "Tyre: %s" % player_tyre
	tyre_age.text = "Age: %d laps" % player_tyre_age
	var fuel = Data.FuelModel.FUEL_LOAD_KG - (current_lap * Data.FuelModel.FUEL_BURN_PER_LAP)
	fuel_info.text = "Fuel: %.1fkg" % max(fuel, 0.0)
	track_temp_label.text = "Track: %.0f°C" % GameState.track_temp
	conditions_label.text = "Wet" if GameState.is_wet else "Dry"
	_update_timing_tower()

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

func _set_speed(speed: int):
	var progress_fraction = lap_timer / lap_duration
	sim_speed = speed
	lap_duration = lap_time_ref / speed
	lap_timer = progress_fraction * lap_duration

func _on_1x_pressed(): _set_speed(1)
func _on_5x_pressed(): _set_speed(5)
func _on_10x_pressed(): _set_speed(10)
func _on_20x_pressed(): _set_speed(20)
func _on_40x_pressed(): _set_speed(40)

func _on_soft_pressed(): _pit_stop("Soft")
func _on_medium_pressed(): _pit_stop("Medium")
func _on_hard_pressed(): _pit_stop("Hard")

func _pit_stop(compound: String):
	player_tyre = compound
	player_tyre_age = 0
	tyre_info.text = "Tyre: %s" % player_tyre
	tyre_age.text = "Age: 0 laps"

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/TeamHub.tscn")

func _setup_timer():
	pass

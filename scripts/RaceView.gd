extends Control

@onready var timing_list = $HBoxContainer/VBoxContainer/ScrollContainer/TimingList
@onready var lap_counter = $HBoxContainer/VBoxContainer/LapCounter
@onready var tyre_info = $HBoxContainer/VBoxContainer2/TyreInfo
@onready var tyre_age = $HBoxContainer/VBoxContainer2/TyreAge
@onready var gap_info = $HBoxContainer/VBoxContainer2/GapInfo

var current_lap: int = 0
var total_laps: int = 0
var player_tyre: String = "Medium"
var player_tyre_age: int = 0
var positions: Array = []
var timer: Timer

func _ready():
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
			"is_player": d.team == GameState.team_name
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
	for p in positions:
		var base_time = 90.0 - (p.pace * 0.3)
		var deg = p.tyre_age * 0.05
		var variation = randf_range(-0.5, 0.5)
		p.gap += base_time + deg + variation
		p.tyre_age += 1

func _update_ui():
	lap_counter.text = "Lap %d / %d" % [current_lap, total_laps]
	tyre_info.text = "Tyre: %s" % player_tyre
	tyre_age.text = "Age: %d laps" % player_tyre_age
	
	for child in timing_list.get_children():
		child.queue_free()
	
	var sorted = positions.duplicate()
	sorted.sort_custom(func(a, b): return a.gap < b.gap)
	
	var leader_gap = sorted[0].gap
	var player_gap_val = 0.0
	
	for i in sorted.size():
		var p = sorted[i]
		var gap_to_leader = p.gap - leader_gap
		var gap_str = "Leader" if i == 0 else "+%.2fs" % gap_to_leader
		if p.is_player:
				player_gap_val = gap_to_leader
		var lbl = Label.new()
		lbl.text = "%d. %s %s" % [i + 1, p.name, gap_str]
		timing_list.add_child(lbl)
		
	gap_info.text = "Gap: +%.2fs" % player_gap_val if player_gap_val > 0 else "Gap: Leader"
		
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

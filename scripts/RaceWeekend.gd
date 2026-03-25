extends Control

@onready var race_name = $VBoxContainer/RaceName
@onready var circuit_info = $VBoxContainer/CircuitInfo

func _ready():
	if GameState.selected_race:
		race_name.text = GameState.selected_race.name
		circuit_info.text = "%s - %d laps / %.3f km" % [
			GameState.selected_race.circuit,
			GameState.selected_race.lap_count,
			GameState.selected_race.lap_length_km
		]
		
func _on_race_pressed():
	get_tree().change_scene_to_file("res://scenes/race/RaceView.tscn")
	
func _on_back_to_hub_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/TeamHub.tscn")

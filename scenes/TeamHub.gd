extends Control

@onready var team_label = $VBoxContainer/HBoxContainer/Label
@onready var budget_label = $VBoxContainer/HBoxContainer/Label2
@onready var season_label = $VBoxContainer/HBoxContainer/Label3
@onready var race_list = $VBoxContainer/TabContainer/Calendar/VBoxContainer/ScrollContainer/RaceList

func _ready():
	team_label.text = GameState.team_name
	budget_label.text = "$%.0fm" % (GameState.budget / 1000000.0)
	season_label.text = "Season: %d" % GameState.season
	call_deferred("_populate_calendar")

func _on_go_to_race_pressed():
	get_tree().change_scene_to_file("res://scenes/race/RaceWeekend.tscn")

func _populate_calendar():
	for race in GameState.calendar:
		var btn = Button.new()
		btn.text = "%s - %d laps" % [race.name, race.lap_count]
		btn.pressed.connect(_on_race_selected.bind(race))
		race_list.add_child(btn)
		
func _on_race_selected(race: Data.Race):
	GameState.selected_race = race
	get_tree().change_scene_to_file("res://scenes/race/RaceWeekend.tscn")

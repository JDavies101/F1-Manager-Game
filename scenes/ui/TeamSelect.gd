extends Control

func _on_team_pressed(team_name: String):
	GameState.team_name = team_name
	GameState.budget = _starting_budget(team_name)
	get_tree().change_scene_to_file("res://scenes/ui/TeamHub.tscn")
	
func _starting_budget(team: String) -> float:
	var budgets = {
		"Williams": 120000000.0, "Audi": 135000000.0,
		"Haas": 140000000.0, "Alpine": 180000000.0,
		"RacingBulls": 175000000.0, "AstonMartin": 220000000.0,
		"Mclaren": 280000000.0, "Mercedes": 320000000.0,
		"Ferrari": 350000000.0, "RedBull": 380000000.0,
		"Cadillac": 100000000.0
	}
	return budgets.get(team, 150000000.0)

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

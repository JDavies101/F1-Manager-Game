extends Node


# Core game state - accessible from any scene
var team_name: String = ""
var budget: float = 0.0
var season: int = 2025
var drivers: Array = []
var player_car: Data.Car = null
var calendar: Array = []
var selected_race: Data.Race = null

signal state_changed

func _ready():
	_init_calendar()
	_init_drivers()
	
func _init_calendar():
	var r1 = Data.Race.new()
	r1.name = "Australian GP"; r1.circuit = "Melbourne"
	r1.lap_count = 58; r1.lap_length_km = 5.278
	
	var r2 = Data.Race.new()
	r2.name = "Chinese GP"; r2.circuit = "Shanghai"
	r2.lap_count = 56; r2.lap_length_km = 5.451

	var r3 = Data.Race.new()
	r3.name = "Japanese GP"; r3.circuit = "Suzuka"
	r3.lap_count = 53; r3.lap_length_km = 5.807

	calendar = [r1, r2, r3]

func _init_drivers():
	var d1 = Data.Driver.new()
	d1.name = "Max Verstappen"; d1.number = 1; d1.team = "RedBull"
	d1.pace = 97; d1.consistency = 95; d1.tyre_management = 88
	d1.overtaking = 95; d1.salary = 55000000; d1.contract_years = 2

	var d2 = Data.Driver.new()
	d2.name = "Lando Norris"; d2.number = 4; d2.team = "McLaren"
	d2.pace = 93; d2.consistency = 88; d2.tyre_management = 85
	d2.overtaking = 89; d2.salary = 20000000; d2.contract_years = 3

	var d3 = Data.Driver.new()
	d3.name = "Charles Leclerc"; d3.number = 16; d3.team = "Ferrari"
	d3.pace = 92; d3.consistency = 85; d3.tyre_management = 82
	d3.overtaking = 87; d3.salary = 18000000; d3.contract_years = 2

	var d4 = Data.Driver.new()
	d4.name = "George Russell"; d4.number = 63; d4.team = "Mercedes"
	d4.pace = 90; d4.consistency = 87; d4.tyre_management = 84
	d4.overtaking = 85; d4.salary = 15000000; d4.contract_years = 2

	var d5 = Data.Driver.new()
	d5.name = "Carlos Sainz"; d5.number = 55; d5.team = "Williams"
	d5.pace = 89; d5.consistency = 88; d5.tyre_management = 86
	d5.overtaking = 84; d5.salary = 12000000; d5.contract_years = 1

	drivers = [d1, d2, d3, d4, d5]

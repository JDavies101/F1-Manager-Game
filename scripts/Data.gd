class_name Data

class Driver:
	var name: String
	var number: int
	var team: String
	var pace: float
	var consistency: float
	var tyre_management: float
	var overtaking: float
	var salary: float
	var contract_years: int

class Car:
	var team: String
	var aero: float
	var power: float
	var reliability: float
	var pit_crew: float

class Race:
	var name: String
	var circuit: String
	var lap_count: int
	var lap_length_km: float

class TyreCompound:
	var name: String
	var base_lap_time_delta: float
	var deg_rate: float
	var cliff_lap: int
	var warmup_laps: int

class FuelModel:
	const FUEL_LOAD_KG = 110.0
	const FUEL_BURN_PER_LAP = 1.8
	const FUEL_TIME_PER_KG = 0.03

class TrackData:
	var name: String
	var tyre_deg_modifier: float
	var fuel_burn_modifier: float
	var overtake_difficulty: float
	var base_lap_time: float

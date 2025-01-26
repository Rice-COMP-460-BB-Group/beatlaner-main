extends Node2D


signal Hit(type: String)

signal Score(type: int, name: String)

signal OpenRhythmGame(tower_type: String)

enum Team {BLUE, RED}
signal TowerDestroyed(team: Team)
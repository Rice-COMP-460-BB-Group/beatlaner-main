extends Node2D


signal Hit(type: String)

signal Score(type: int, name: String)

signal OpenRhythmGame(tower_type: String, tower)

signal WaveSpawned()


enum Team {BLUE, RED}
signal TowerDestroyed(team: Team)


signal ScrollSpeedChange(new_speed: float)

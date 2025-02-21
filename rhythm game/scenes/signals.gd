extends Node2D


signal Hit(type: String)

signal Score(type: int, name: String)

signal OpenRhythmGame(tower_type: String, tower)

signal WaveSpawned()


enum Team {BLUE, RED}
signal TowerDestroyed(tower: Team, pos: Vector2)
signal NexusDestroyed(tower: Team, pos: Vector2)


signal ScrollSpeedChange(new_speed: float)

signal PowerupGet(player: String, powerup: String)

extends Node2D
@onready var lane_manager = $Map/LaneManager
@onready var minimap = $Map/Player/HUD/Minimap
var map_scene = preload("res://map/Map.tscn")

var spawner_scene = load("res://minions/spawner.tscn")

var spawner = null
var rhythm_game_instance

var tower_type
var current_tower

enum Team {BLUE, RED}

var red_score = 0
var blue_score = 0

func _ready():
	print("game started")
	
	spawner = get_node("Spawner")
	spawner.spawner_init()
	Signals.OpenRhythmGame.connect(OpenRhythmGame)

	Signals.TowerDestroyed.connect(on_tower_destroyed)

func on_tower_destroyed(team: Team):
	if team == Team.RED:
		red_score += 1
	else:
		blue_score += 1
	
	if red_score == 3:
		get_tree().change_scene_to_file.bind("res://map/game_over.tscn").call_deferred()
	elif blue_score == 3:
		get_tree().change_scene_to_file.bind("res://map/game_win.tscn").call_deferred()
	
func OpenRhythmGame(tmp_tower_type: String, tower):
	if $RhythmLayer.get_children():
		return
	tower_type = tmp_tower_type
	var rhythm_game_scene = load("res://rhythm game/scenes/background.tscn")
	rhythm_game_instance = rhythm_game_scene.instantiate()
	current_tower = tower
	$RhythmLayer.add_child(rhythm_game_instance)
func _process(delta):
	if len($RhythmLayer.get_children()) and Input.is_action_just_pressed("escape rhythm game"):
		var score = rhythm_game_instance.get_score()
		Signals.Score.emit(score, tower_type)
		current_tower.update_score(score)
		$RhythmLayer.remove_child(rhythm_game_instance)
		
	
	$"WaveLayer/Wave Spawning/Timer Label".text = "Wave Spawning: " + str(floor($"Wave Timer".time_left)) + "s"
	$"WaveLayer/Wave Spawning/Mana".text = "Current Mana:"

func _on_debugmenu_spawn_wave(spawn_request: Dictionary, is_friendly: bool) -> void:
	
	print(spawn_request, "here from main!")
	print(spawner)
	if spawner:
		
		spawner.spawn_friendly_wave(spawn_request, is_friendly)


func _on_debugmenu_toggle_enemy_wave(state: bool) -> void:
	
	if state:
		spawner.enable_timer()
	else:
		spawner.disable_timer()
	pass # Replace with function body.


func _on_debugmenu_freeze_spell(lane: int, friendly: bool) -> void:
	print("calling freeze")
	#lane_manager.freeze_current_enemies(lane, 0) # Replace with function body.
	var cur_map = lane_manager.get_minimap_info()
	print("from main:",cur_map)
	minimap.refresh_minimap(cur_map["blue"],cur_map["red"])
	

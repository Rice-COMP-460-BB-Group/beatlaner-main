extends Node2D
@onready var lane_manager = $Map/LaneManager
@onready var minimap = $Map/Player/HUD/Minimap
@export var PlayerScene: PackedScene
@export var current_difficulty = Difficulty.EASY
enum Difficulty {EASY, MEDIUM, HARD}

var map_scene = preload("res://map/Map.tscn")


var spawner_scene = load("res://minions/spawner.tscn")



var spawner = null
var rhythm_game_instance

var tower_type
var current_tower

enum Team {BLUE, RED}
var players = []





func _ready():
	print("Main scene _ready() triggered. Instance ID:", self.get_instance_id())
	#var spawners = get_tree().get_nodes_in_group("PlayerSpawnPoint")
	#print("game started", spawners)
	#for spawner in spawners:
		#print("spawner", spawner.name)
	#var index = 0
	##print("players", GameManager.Players)
	#for i in GameManager.Players:
		#print("player bruh", i)
		#var currentPlayer = PlayerScene.instantiate()
		#currentPlayer.name = str(GameManager.Players[i].id)
		#add_child(currentPlayer)
		#
		## Assign spawn point and immediately increment index
		##for spawn in :
			##print(spawn.name + " " + index)
			##if spawn.name == str(index):
		#currentPlayer.global_position = spawners[index].global_position
		#print("idx", index, currentPlayer.global_position)
				##print('matches', spawn.global_position)
				##break  # Exit the loop once assigned
		#
		#index += 1  # Move to next spawn point after assignment
	var spawns = get_tree().get_nodes_in_group("PlayerSpawnPoint")
	var index = 0
	var curr_team = Team.RED
	# Create a sorted array of player data based on id
	var sorted_players = GameManager.Players.values()
	sorted_players.sort_custom(func(a, b): return a.id < b.id)
	
	for player_data in sorted_players:
		var currentPlayer = PlayerScene.instantiate()
		currentPlayer.game_difficulty = current_difficulty
		currentPlayer.name = str(player_data.id)
		currentPlayer.team = curr_team
		add_child(currentPlayer)
		currentPlayer.visible = true
		curr_team = not curr_team
		
		currentPlayer.global_position = spawns[index].global_position
		players.append(currentPlayer)
		var sprite = currentPlayer.get_node("AnimatedSprite2D")
		index += 1
	spawner = get_node("Spawner")
	spawner.spawner_init()
	#Signals.OpenRhythmGame.connect(OpenRhythmGame)

	#Signals.PowerupGet.connect(_on_power_get)
	$BackgroundMusic.connect("finished", Callable(self,"_on_loop_sound").bind($BackgroundMusic))
	$BackgroundMusic.play()
func _on_loop_sound(player):
	$BackgroundMusic.stream_paused = false
	$BackgroundMusic.play()





func _process(delta):
	pass

		
	
	#if len($RhythmLayer.get_children()) and Input.is_action_just_pressed("escape rhythm game"):
		#var score = rhythm_game_instance.get_score()
		#Signals.Score.emit(score, tower_type)
		#current_tower.update_score(score)
		#$RhythmLayer.remove_child(rhythm_game_instance)
		
	
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
	lane_manager.freeze_current_enemies(lane, 0) # Replace with function body.
	var cur_map = lane_manager.get_minimap_info()

	minimap.refresh_minimap(cur_map["blue"],cur_map["red"])
	


func _on_map_update_refresh_timeout() -> void:
	var cur_map = lane_manager.get_minimap_info()
	print('map timeout!')
	for player in players:
		if is_instance_valid(player) and is_instance_valid(player.get_minimap()):
			player.get_minimap().refresh_minimap(cur_map["blue"],cur_map["red"])

extends Node2D
@onready var lane_manager = $Map/LaneManager
@onready var minimap = $Map/Player/HUD/Minimap
@export var PlayerScene: PackedScene


var map_scene = preload("res://map/Map.tscn")


var spawner_scene = load("res://minions/spawner.tscn")

var destroy_enemy_banner = preload("res://assets/enemy-banner.png")
var destroy_friendly_banner = preload("res://assets/friendly-banner.png")

var win_banner = preload("res://assets/Victory.png")
var lose_banner = preload("res://assets/Defeat.png")

var spawner = null
var rhythm_game_instance

var tower_type
var current_tower

enum Team {BLUE, RED}
var players = []


var red_score = 0
var blue_score = 0



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
	for player_data in GameManager.Players.values():  # Iterate properly over dictionary		
		var currentPlayer = PlayerScene.instantiate()
		currentPlayer.name = str(player_data.id)
		currentPlayer.team = curr_team
		add_child(currentPlayer)
		currentPlayer.visible = true
		curr_team = not curr_team
		print("playuers team", currentPlayer.team)
		currentPlayer.global_position = spawns[index].global_position
		players.append(currentPlayer)
		var sprite = currentPlayer.get_node("AnimatedSprite2D")
		index += 1
	spawner = get_node("Spawner")
	spawner.spawner_init()
	Signals.OpenRhythmGame.connect(OpenRhythmGame)

	Signals.TowerDestroyed.connect(on_tower_destroyed)
	#Signals.PowerupGet.connect(_on_power_get)
	$BackgroundMusic.connect("finished", Callable(self,"_on_loop_sound").bind($BackgroundMusic))
	$BackgroundMusic.play()
func _on_loop_sound(player):
	$BackgroundMusic.stream_paused = false
	$BackgroundMusic.play()



# Add this near the top of your script
@rpc("any_peer", "call_local")
func show_victory():
	var banner = $BannerLayer/Banner
	banner.texture = win_banner
	banner.modulate.a = 0
	banner.show()

	var fade_in = banner.create_tween()
	fade_in.tween_property(banner, "modulate:a", 1, .5)
	await fade_in.finished
	await get_tree().create_timer(2).timeout
	get_tree().change_scene_to_file("res://map/game_win.tscn")

@rpc("any_peer", "call_local")
func show_defeat():
	var banner = $BannerLayer/Banner
	banner.texture = lose_banner
	banner.modulate.a = 0
	banner.show()

	var fade_in = banner.create_tween()
	fade_in.tween_property(banner, "modulate:a", 1, .5)
	await fade_in.finished
	await get_tree().create_timer(2).timeout
	get_tree().change_scene_to_file("res://map/game_over.tscn")

func on_tower_destroyed(team: Team, pos: Vector2):
	if team == Team.RED:
		red_score += 1
	else:
		blue_score += 1

	if red_score == 3:
		# Notify all players
		for player in players:
			if player.team == Team.BLUE:
				show_defeat.rpc_id(player.get_instance_id())  # Notify RED team (loss)
			else:
				show_victory.rpc_id(player.get_instance_id())  # Notify BLUE team (win)
	elif blue_score == 3:
		# Notify all players
		for player in players:
			if player.team == Team.RED:
				show_defeat.rpc_id(player.get_instance_id())  # Notify BLUE team (loss)
			else:
				show_victory.rpc_id(player.get_instance_id())  # Notify RED team (win)
func OpenRhythmGame(tmp_tower_type: String, tower):
	if $RhythmLayer.get_children():
		return
	tower_type = tmp_tower_type
	var rhythm_game_scene = load("res://rhythm game/scenes/background.tscn")
	rhythm_game_instance = rhythm_game_scene.instantiate()
	current_tower = tower
	$RhythmLayer.add_child(rhythm_game_instance)
	
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
		player.get_minimap().refresh_minimap(cur_map["blue"],cur_map["red"])

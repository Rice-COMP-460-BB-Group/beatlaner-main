extends Node2D
@onready var lane_manager = $Map/LaneManager
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

var red_score = 0
var blue_score = 0

var player1_powerups = {
	"freeze": 0,
	"damage_powerup": 0
}
var player2_powerups = {
	"freeze": 0,
	"damage_powerup": 0
}

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
	for spawn in spawns:
		print("Spawn:", spawn.name, "Position:", spawn.global_position)
	var players = []
	var index = 0
	for player_data in GameManager.Players.values():  # Iterate properly over dictionary		
		#if index == 0:
			#index += 1
			#continue
		var currentPlayer = PlayerScene.instantiate()
		currentPlayer.name = str(player_data.id)
		add_child(currentPlayer)
		currentPlayer.visible = true
		currentPlayer.global_position = spawns[index].global_position
		players.append(currentPlayer)
		var sprite = currentPlayer.get_node("AnimatedSprite2D")
		print("sprite", sprite)
		print("Assigned player", currentPlayer.name, "to", spawns[index].global_position)
		print("Player position set to:", currentPlayer.global_position)
		index += 1
	for player in players:
		print("player", player.name, player.global_position)
	spawner = get_node("Spawner")
	spawner.spawner_init()
	Signals.OpenRhythmGame.connect(OpenRhythmGame)

	Signals.TowerDestroyed.connect(on_tower_destroyed)
	Signals.PowerupGet.connect(_on_power_get)


func _on_power_get(player: String, powerup: String):
	if player == "player1":
		player1_powerups[powerup] += 1
	else:
		player2_powerups[powerup] += 1
	print('new powerups', player1_powerups)


func on_tower_destroyed(team: Team, pos: Vector2):
	if team == Team.RED:
		red_score += 1
	else:
		blue_score += 1
	
	var banner = $BannerLayer/Banner

	if red_score == 3:
		banner.texture = lose_banner
		banner.modulate.a = 0
		banner.show()

		var fade_in = banner.create_tween()
		fade_in.tween_property(banner, "modulate:a", 1, .5)
		var camera = $Map/Player/Camera2D

		var tween = create_tween()
		tween.tween_property(camera, "position", camera.to_local(pos), 1.0)
		Engine.time_scale = 0.5


		await fade_in.finished
		await tween.finished
		await get_tree().create_timer(.5).timeout
		Engine.time_scale = 1

		banner.hide()
		get_tree().change_scene_to_file.bind("res://map/game_over.tscn").call_deferred()
	elif blue_score == 3:
		banner.texture = win_banner
		banner.modulate.a = 0
		banner.show()

		var fade_in = banner.create_tween()
		fade_in.tween_property(banner, "modulate:a", 1, .5)
		var camera = $Map/Player/Camera2D

		var tween = create_tween()
		tween.tween_property(camera, "position", camera.to_local(pos), 1.0)
		Engine.time_scale = 0.5

		await fade_in.finished
		await tween.finished
		await get_tree().create_timer(.5).timeout
		Engine.time_scale = 1
		
		banner.hide()
		get_tree().change_scene_to_file.bind("res://map/game_win.tscn").call_deferred()
	else:
		if team == Team.RED:
			banner.texture = win_banner
		else:
			banner.texture = destroy_enemy_banner
		
		banner.modulate.a = 0
		banner.show()
		
		var fade_in = banner.create_tween()
		fade_in.tween_property(banner, "modulate:a", 1, .5)
		await fade_in.finished
		
		await get_tree().create_timer(1).timeout
		
		var fade_out = banner.create_tween()
		fade_out.tween_property(banner, "modulate:a", 0, .5)
		await fade_out.finished
		
		banner.hide()
	
func OpenRhythmGame(tmp_tower_type: String, tower):
	if $RhythmLayer.get_children():
		return
	tower_type = tmp_tower_type
	var rhythm_game_scene = load("res://rhythm game/scenes/background.tscn")
	rhythm_game_instance = rhythm_game_scene.instantiate()
	current_tower = tower
	$RhythmLayer.add_child(rhythm_game_instance)
	
func _process(delta):
	if Input.is_action_just_pressed("freeze") and player1_powerups["freeze"] and not len($RhythmLayer.get_children()):
		player1_powerups["freeze"] -= 1
		lane_manager.freeze_current_enemies(0, 0)
		lane_manager.freeze_current_enemies(1, 0)
		lane_manager.freeze_current_enemies(2, 0)
	if Input.is_action_just_pressed("damage_powerup") and player1_powerups["damage_powerup"] and not len($RhythmLayer.get_children()):
		print("damage")
		player1_powerups["damage_powerup"] -= 1
		lane_manager.damage_powerup(0)

		
	
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
	lane_manager.freeze_current_enemies(lane, 0) # Replace with function body.

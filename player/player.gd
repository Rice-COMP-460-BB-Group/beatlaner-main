extends CharacterBody2D

class_name Player

var bpm = 175
@onready var damage_overlay = $"HUD/Damage indic"
@onready var powerup_labrl = $HUD/Stats/PowerUpLabel
@export var flash_color: Color = Color(4, 4, 4, 1)  # White by default
@export var rest_color: Color = Color(0, 0, 0, 0)   # Transparent by default
@export var flash_duration_percent: float = 0.25    # How long the flash stays visible (as percentage of beat)
var seconds_per_beat: float = 60.0 / bpm
var last_rhythm_score:int = 0
var timer: float = 0.0
var is_flashing: bool = false
@export var damage = 49
@export var attack_speed = .35
@export var team: Team
@export var respawn_position: Vector2
@onready var rhythm_game_scene = preload("res://rhythm game/scenes/background.tscn");
@export var game_difficulty: Difficulty
@export var can_use_nexus: bool
@onready var damage_icon = preload("res://assets/damage.png")
@onready var freeze_icon = preload("res://assets/freeze.png")
@onready var heal_icon = preload("res://assets/health_potion.png")
@onready var powerup_frame = $HUD/Stats/PowerupFrame/Powerup
func get_keybind_as_string(input_action: String) -> String:
	var events = InputMap.action_get_events(input_action)
	
	
	for event in events:
		if event is InputEventKey:
			return event.as_text()
			
		
	return "NULL"
var powerup_label_default = "POWERUP:NONE"
@onready var rhythm_keyname:String =get_keybind_as_string("toggle_rhythm_game")
@onready var upgrade_minions_keyname:String = get_keybind_as_string("upgrade_minions")
@onready var upgrade_player_keyname:String = get_keybind_as_string("upgrade_player")
@onready var has_deployed = false
var disable_movement = false
@onready var minimap = $HUD/Minimap
var player_level = 1
var minion_level = 1
enum Difficulty {EASY = 0,MEDIUM = 1, HARD = 2}
enum Team {BLUE = 0, RED = 1}

var player_powerup = null

var rhythm_game_instance= null
var powerups = ["freeze", "damage_powerup", "heal"]



@onready var tutorialMSGs :Dictionary = {
	"rhythm": "Press " + rhythm_keyname + " to start building Mana. Once the bar is full,
	press R to stop building mana.",
	"deploy": "Press 1,2, or 3 to deploy minions to the top,middle, or bottom lanes!",
	"upgrade": "Try Upgrading!"
	}
@onready var has_upgraded = false

#var banner_tween = create_tween()

var last_attack = attack_speed

const floating_text_scene = preload("res://player/floating_text.tscn")
const ACCELERATION = 1000
signal wave_request(pos: int, size: int,team:bool,level:int)
const FRICTION = 10000

const MAX_SPEED = 180
const DASH_SPEED = 5000

var dash_timer = 0.0
var is_dashing = false
enum {IDLE, WALK}

var state = IDLE
var is_rhythm_game_open = false
@onready var animationTree = $AnimationTree
@onready var weapon = $Weapon
@onready var state_machine = animationTree["parameters/playback"]
@onready var camera = $Camera2D as Camera2D
# horrendous use of absolute path
@onready var LaneManager = get_node("/root/Main/Map/LaneManager")

var blend_position: Vector2 = Vector2.ZERO
var blend_pos_paths = ["parameters/Idle/id_BlendSpace2D/blend_position", "parameters/Moving/BlendSpace2D/blend_position"]
var current_score = 0

var last_input_direction = Vector2.ZERO
var animTree_state_keys = [
	"Idle", "Moving"
]

var sync_velocity := Vector2.ZERO
var sync_is_dashing := false

var old_collision_size

func _ready() -> void:
	$Metronome.wait_time = (60.0 / bpm)
	cycle_duration = 2 * $Metronome.wait_time # Full cycle duration (1 second)
	frame_duration = cycle_duration / (total_metronome_frames - 1) # 1/12 ≈ 0.0833s
	$Metronome.start()
	$Slice/SliceAnimation.frame = 4
	$HUD/Stats/UpgradeStats.modulate.a = 0

	$HealthComponent.set_color(team)
	rhythm_game_instance = rhythm_game_scene.instantiate()
	rhythm_game_instance.set_difficulty(game_difficulty)
	$RhythmLayer1.add_child(rhythm_game_instance)
	
	rhythm_game_instance.hide()
	rhythm_game_instance.disable()
	Signals.NexusDestroyed.connect(on_nexus_destroyed)
	Signals.TowerDestroyed.connect(on_tower_destroyed)
	
	$HealthComponent.health_decreased.connect(_on_health_decreased)
	$HealthComponent.health_increased.connect(_on_health_increased)

	old_collision_size = $Slice/SliceArea/CollisionShape2D.shape.size
	if team == Team.RED:
		#print("team", team)
		respawn_position = Vector2(651, 3379)
	else:
		respawn_position = Vector2(3401, 600)

	#print("respawn pos", respawn_position, team)
	$HUD/Stats.hide()
	$HUD.hide()
	
	$MultiplayerSynchronizer.set_multiplayer_authority(str(name).to_int())
	if $MultiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():

		camera.make_current()
		$HUD/Stats.show()
		$HUD.show()
	$HUD/DialogBox/Label.text = tutorialMSGs["rhythm"]
	if "--server" in OS.get_cmdline_args():
		camera.make_current()
func _on_health_decreased():
	show_damage_flash()
func _on_health_increased():
	show_health_flash()
func show_tooltip(action: String, text: String):
	print("[player.gd]","show tooltip")
	
	$HUD/Hints.add_hint(action, text);

func hide_tooltip(action: String):
	$HUD/Hints.remove_hint(action);
	
	
func move(delta):
	if not $MultiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
		return
	if disable_movement or not is_alive:
		return
	#print('moving')
	if is_rhythm_game_open:
		state = IDLE
		velocity = Vector2.ZERO
		return
	var input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if velocity and Input.is_action_just_pressed("Dash") and not $HUD/Stats/Respawning.visible:
		$DashSound.play()
		start_dash.rpc()
		#update_mana(current_score - 1)
	if is_dashing:
		sync_velocity = last_input_direction * DASH_SPEED
		velocity = sync_velocity
	else:
		
		if input_vector == Vector2.ZERO:
			state = IDLE
			last_input_direction = Vector2.ZERO
			velocity = Vector2.ZERO
		
		else:
			input_vector = input_vector.normalized()
			last_input_direction = input_vector
			state = WALK
			apply_movement(input_vector * MAX_SPEED)
			blend_position = input_vector
		
		
	move_and_slide()
@rpc("any_peer", "call_local")
func start_dash():
	print("dashing")
	if $MultiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
		if last_input_direction != Vector2.ZERO:
			is_dashing = true
			sync_is_dashing = true
			dash_timer = .02
			#self.collision_mask = (self.collision_mask & ~(1 << 2))
			create_afterimage.rpc()
	#print("new collision layer", self.collision_layer)
		

func update_mana(score: int):
	$HUD/Stats/ManaBar.set_manabar(score)
	
var beat_half_count := 0
var total_metronome_frames := 13
const centered_frames := [0, 6]
var half_beat_duration: float
var frame_duration: float
var cycle_duration: float

var destroy_enemy_banner = preload("res://assets/enemy-banner.png")
var destroy_friendly_banner = preload("res://assets/friendly-banner.png")

var win_banner = preload("res://assets/Victory.png")
var lose_banner = preload("res://assets/Defeat.png")



# Add this near the top of your script
func show_victory(pos: Vector2):
	print("showing victory", team, multiplayer.get_unique_id())
	$AnimationTree.active = false
	disable_movement = true

	var banner = $HUD/Stats/Banner
	banner.texture = win_banner
	banner.modulate.a = 0
	banner.show()

	var fade_in = banner.create_tween()
	fade_in.tween_property(banner, "modulate:a", 1, .5)
	var camera = $Camera2D

	var tween = create_tween()
	tween.tween_property(camera, "global_position", pos, 1.0)

	await fade_in.finished
	await tween.finished
	await get_tree().create_timer(1.0).timeout

	banner.hide()
	print("changing scene")
	change_to_scene("res://map/game_win.tscn")

func show_defeat(pos: Vector2):
	print("showing defeat", team, multiplayer.get_unique_id())
	$AnimationTree.active = false
	disable_movement = true
	
	var banner = $HUD/Stats/Banner
	banner.texture = lose_banner
	banner.modulate.a = 0
	banner.show()

	var fade_in = banner.create_tween()
	fade_in.tween_property(banner, "modulate:a", 1, .5)
	var camera = $Camera2D

	var tween = create_tween()
	tween.tween_property(camera, "global_position", pos, 1.0)

	await fade_in.finished
	await tween.finished
	await get_tree().create_timer(1.0).timeout

	banner.hide()
	print("changing scene")

	change_to_scene("res://map/game_over.tscn")

func change_to_scene(scene_path: String):
	var children = get_tree().get_root().get_children()
	var scene = load(scene_path).instantiate()
	get_tree().root.add_child(scene)

	for child in children:
		if child.name == "GameManager" or child.name == "Signals":
			if child.name == "GameManager":
				child.Players = {}
			continue
		if child.name == "Titlescreen":
			child.peer = null
		child.call_deferred("queue_free")



func on_nexus_destroyed(nexus_destroyed_team: Team, pos: Vector2):
	if $MultiplayerSynchronizer.is_multiplayer_authority():
		if team == nexus_destroyed_team:
			show_defeat(pos)
		else:
			show_victory(pos)
		
		
func on_tower_destroyed(tower_team: Team, pos: Vector2):
	var banner = $HUD/Stats/Banner
	if tower_team == team:
		banner.texture = destroy_friendly_banner
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
			
func _on_metronome_timeout():
	beat_half_count += 1

func _process(delta: float) -> void:
	var elapsed_in_cycle = (beat_half_count % 2) * $Metronome.wait_time + ($Metronome.wait_time - $Metronome.time_left)
	var current_frame = int(round(elapsed_in_cycle / frame_duration))
	
	if abs(elapsed_in_cycle - 0.5) < 0.01:
		current_frame = 6
	elif abs(elapsed_in_cycle - 1.0) < 0.01:
		current_frame = 12
	
	#$HUD/Stats/MetronomeContainer/MetronomeAnimation.frame = current_frame % total_metronome_frames

	if $HUD/Stats/MetronomeContainer/MetronomeAnimation.frame in centered_frames:
		#print("fall off", falloff_curve(), " ", $HUD/Stats/MetronomeContainer/MetronomeAnimation.frame)
		var tween = create_tween()
		tween.tween_property($HUD/Stats/MetronomeContainer/MetronomeAnimation, "modulate", Color(2, 2, 2, 1), 0.1)
		tween.tween_property($HUD/Stats/MetronomeContainer/MetronomeAnimation, "modulate", Color(1, 1, 1, 1), 0.1)
@rpc("any_peer", "call_local")
func create_afterimage():
	var jump_duration = 0.5 # How long the jump lasts (adjust as needed)
	var num_afterimages = 3 # Number of afterimages you want to create
	var interval = jump_duration / num_afterimages # Time between afterimages during jump

	var base_interval = 0.05 # Adjust for how frequently afterimages appear

	for i in range(num_afterimages):
		# Fixed delay between afterimage creation
		await get_tree().create_timer(base_interval)

		var afterimage = AnimatedSprite2D.new()
		afterimage.sprite_frames = $AnimatedSprite2D.sprite_frames
		afterimage.animation = $AnimatedSprite2D.animation
		afterimage.frame = $AnimatedSprite2D.frame
		afterimage.global_position = global_position
		afterimage.flip_h = $AnimatedSprite2D.flip_h
		afterimage.modulate = Color(1, 1, 1, 0.5)

		get_parent().add_child(afterimage)

		# Quadratic fade-out duration (first afterimages last longer)
		var fade_duration = 0.1 # Adjusted timing formula

		var tween = afterimage.create_tween()
		tween.tween_property(afterimage, "modulate:a", 0, fade_duration)

		await tween.finished
		afterimage.queue_free()
		
@rpc("any_peer", "call_local", "reliable")
func request_wave_spawn(pos: int, size: int, team: bool,level:int):
	if multiplayer.is_server():
		LaneManager.wave_request(pos, size, team,level)

func show_damage_flash():
	damage_overlay.modulate.a = 0.6  # Start with a visible red hue
	var tween = create_tween()
	tween.tween_property(damage_overlay, "modulate:a", 0.0, 0.5).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
var last_combo = 0

func show_health_flash():
	damage_overlay.modulate = Color(0, 1, 0, 0.6)  # Green with 60% opacity
	var tween = create_tween()
	tween.tween_property(damage_overlay, "modulate:a", 0.0, 0.5).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)

func upgrade_player() -> void:
	damage = damage + 1
	$HealthComponent.increase_max_health(20)
func _physics_process(delta: float) -> void:
	if $MultiplayerSynchronizer.is_multiplayer_authority():
		if is_rhythm_game_open:
			var combo = rhythm_game_instance.get_combo()
			#if combo and not combo % 100 and combo > last_combo and player_powerup == null:
				#var rand_powerup = powerups[randi_range(0, len(powerups) - 1)]
				#player_powerup = rand_powerup
				#if rand_powerup == "freeze":
					#powerup_frame.texture = freeze_icon
				#elif rand_powerup == "damage_powerup":
					#powerup_frame.texture = damage_icon
				#elif rand_powerup == "heal":
					#powerup_frame.texture = damage_icon # change later


			last_combo = combo
			
			var score = rhythm_game_instance.get_score()
			var tmp_score: float
			#if $HealthComponent.currentHealth > 0:
			var score_delta = score - last_rhythm_score
			last_rhythm_score = score
			tmp_score = min(current_score + int(score_delta / 50), 300)
			print("[player.gd] tmp score is",tmp_score)
			current_score = tmp_score
			update_mana(tmp_score)
		if is_dashing:
			dash_timer -= delta
			if dash_timer <= 0:
				is_dashing = false
				sync_is_dashing = false
				#self.collision_mask |= (1 << 2)

		if Input.is_action_just_pressed("toggle_rhythm_game"):
			$DashSound.play()
			handle_rhythm_callback()
		
		else:
			$HUD/Stats/MinionUpgradePrompt.visible = false
		if current_score >= 160:
			$HUD/Stats/PlayerUpgradePrompt.text = "UPGRADE(160):"+upgrade_player_keyname
			$HUD/Stats/PlayerUpgradePrompt.visible = true
		else:
			$HUD/Stats/PlayerUpgradePrompt.visible = false
		if current_score >= 30:
			$HUD/Stats/MinionUpgradePrompt.text = "DEPLOY(30):1/2/3"
			if !has_deployed and !is_rhythm_game_open:
				$HUD/DialogBox/Label.text = tutorialMSGs["deploy"]
				#$HUD/DialogBox/Label.add_theme_font_size_override("font_size",13)
				$HUD/DialogBox.visible = true
				
			if Input.is_action_just_pressed("Dispatch_Top"):
				current_score = max(current_score - 30, 0)
				request_wave_spawn.rpc(0, 3, team,minion_level)
				update_mana(current_score)
				$HUD/DialogBox.visible = false
				has_deployed = true
			if Input.is_action_just_pressed("Dispatch_Mid"):
				current_score = max(current_score - 30, 0)
				request_wave_spawn.rpc(1, 3, team,minion_level)
				update_mana(current_score)
				$HUD/DialogBox.visible = false
				has_deployed = true
			if Input.is_action_just_pressed("Dispatch_Low"):
				current_score= max(current_score - 30, 0)
				request_wave_spawn.rpc(2, 3, team,minion_level)
				update_mana(current_score)
				$HUD/DialogBox.visible = false
				has_deployed = true
		if current_score >=100:
			$HUD/Stats/MinionUpgradePrompt.text = "UPGRADE(100):"+upgrade_minions_keyname
			$HUD/Stats/MinionUpgradePrompt.visible = true
		if Input.is_action_just_pressed("use_powerup"):
			if player_powerup != null:
				if player_powerup == "freeze":
					LaneManager.freeze_current_enemies.rpc(0, team)
					LaneManager.freeze_current_enemies.rpc(1, team)
					LaneManager.freeze_current_enemies.rpc(2, team)
					print('using freeze')
					powerup_labrl.text = powerup_label_default
					$FreezePowerupSound.play()
				elif player_powerup == "damage_powerup":
					LaneManager.damage_powerup.rpc(team)
					print('using damage')
					powerup_labrl.text = powerup_label_default
					$DamagePowerupSound.play()
				elif player_powerup == "heal":
					$HealthComponent.rpc("increase_health", 100)
					$HealPowerupSound.play()
					powerup_labrl.text = powerup_label_default
					print('using health')

				
				powerup_frame.hide()
				player_powerup = null

				$HUD/Hints.remove_hint("use_powerup");
					

		if Input.is_action_just_pressed("Attack"):
			if $HealthComponent.currentHealth <= 0 or last_attack < attack_speed:
				return
			
			last_attack = 0

			play_slice_anim.rpc(global_position.angle_to_point(get_global_mouse_position()))

			var foundAttack = false

			for body in $Slice/SliceArea.get_overlapping_bodies():
				if body != self and (body is Minion or body is Player or body is Tower or body is Nexus) and body.team != team:
					if body.has_node("HealthComponent"):
						foundAttack = true
						body.get_node("HealthComponent").decrease_health.rpc((damage + player_level) + (damage + player_level) * falloff_curve())
						if body.get_node("HealthComponent").get_current_health() <= 0:
							
							$HUD/Stats/ManaBar.increase_mana(5)

			if foundAttack:
				var floating_text = floating_text_scene.instantiate()
				floating_text.text = str(round(damage + damage * falloff_curve()))
				floating_text.critical = falloff_curve()
				floating_text.rotation = deg_to_rad(randf_range(-10, 10))
				$HUD/Stats/DamagePosition.add_child(floating_text)
		last_attack += delta
		move(delta)
		if Input.is_action_just_pressed("upgrade_minions"):
			if current_score >= 100:
				minion_level += 1
				current_score -= 100
				$HUD/Stats/MinionLvl.text = str(minion_level)
				print("new score", current_score)
				update_mana(current_score)
		if Input.is_action_just_pressed("upgrade_player"):
			print('upgrading self')
			if current_score >= 160:
				player_level += 1
				$HUD/Stats/PlayerLevel.text = str(player_level)
				current_score -= 160
				update_mana(current_score)
				
				var oldHP = $HealthComponent.get_max_health()
				#$HealthComponent.upgrade_health()
				
				$HealthComponent.rpc("upgrade_health")
				$HUD/Stats/UpgradeStats/LevelUpgradeLabel.text = "Level: " + str(player_level - 1) + " -> " + str(player_level)
				$HUD/Stats/UpgradeStats/DamageUpgradeLabel.text = "Damage: " + str(damage + player_level - 1) + " -> " + str(damage + player_level)
				$HUD/Stats/UpgradeStats/HPUpgradeLabel.text = "HP: " + str(oldHP) + " -> " + str($HealthComponent.get_max_health())
				#$UpgradeStats.show()
				var tween = get_tree().create_tween()
				tween.tween_property($HUD/Stats/UpgradeStats, "modulate:a", 1, 0.5)
				tween.tween_property($HUD/Stats/UpgradeStats, "modulate:a", 0, 0.5).set_delay(3)

				var old_pos = $HUD/Stats/LevelUpBanner.position.x
				$HUD/Stats/LevelUpBanner/TextLabels/Damage.text = str(damage + player_level - 1) + " → " + str(damage + player_level)
				$HUD/Stats/LevelUpBanner/TextLabels/Health.text = str(oldHP) + " → " + str($HealthComponent.get_max_health())
				$HUD/Stats/LevelUpBanner/TextLabels/Level.text = str(player_level - 1) + " → " + str(player_level)

				#if !banner_tween.is_running():
				var banner_tween = create_tween()
				banner_tween.tween_property($HUD/Stats/LevelUpBanner, "position:x", $HUD/Stats/LevelUpBanner.position.x-($HUD/Stats/LevelUpBanner/Backdrop.size.x * $HUD/Stats/LevelUpBanner.scale.x), 0.5).set_trans(Tween.TRANS_QUAD)
				banner_tween.tween_property($HUD/Stats/LevelUpBanner, "position:x", old_pos, 0.5).set_trans(Tween.TRANS_QUAD).set_delay(2.0)

		animate()
		
	else:
		$AnimatedSprite2D.animation = "IdleRight"

@rpc("any_peer", "call_local")
func play_slice_anim(angle_to_cursor):
	var slice = $Slice
	slice.position = Vector2.RIGHT.rotated(angle_to_cursor) * 20
	slice.rotation = angle_to_cursor

	var white = Color(1, 1, 1, 1)
	var yellow = Color(1, 1, 0, 1)
	var orange = Color(1, 0.5, 0, 1)
	var red = Color(1, 0, 0, 1)

	var critical = falloff_curve()
	var final_color
	if critical < 0.5:
		final_color = white.lerp(yellow, critical * 2)
	elif critical < 0.75:
		final_color = yellow.lerp(orange, (critical - 0.5) * 4)
	else:
		final_color = orange.lerp(red, (critical - 0.75) * 4)
	
	slice.scale = Vector2(1.0 + critical, 1.0 + critical)
	slice.modulate = final_color

	$Slice/SliceArea/CollisionShape2D.shape.size = old_collision_size * (1.0 + critical)
	$Slice/SliceAnimation.play()
	$Slice/AudioStreamPlayer.play()
func escape_rhythm_game():
	if is_instance_valid(rhythm_game_instance):
		#$RhythmLayer1.remove_child(rhythm_game_instance)
	
		#var score = rhythm_game_instance.get_score()
		#rhythm_game_instance.reset_score()
		#var notes = get_tree().get_nodes_in_group("mania_note_instance")
		##print("notes", notes)
		##for note in notes:
			##note.queue_free()
		#current_score = min(current_score + int(score / 3000), 300)
		#update_mana(current_score)
		last_rhythm_score = rhythm_game_instance.get_score()
		is_rhythm_game_open = false
func get_minimap():
	return minimap

@rpc("any_peer", "call_local")
func add_powerup(powerup):
	
	if player_powerup == null:
		if powerup == "freeze":
			powerup_labrl.text = "FREEZE: Z"
			powerup_frame.texture = freeze_icon
		elif powerup == "damage_powerup":
			powerup_labrl.text = "DAMAGE UP: Z"
			powerup_frame.texture = damage_icon
		elif powerup == "heal":
			powerup_labrl.text =  "HEAL: Z"
			powerup_frame.texture = heal_icon
		powerup_frame.show()
		player_powerup = powerup

		$HUD/Hints.add_hint("use_powerup", "Use Powerup")

func handle_rhythm_callback():
	if is_rhythm_game_open:
		#$RhythmLayer1.remove_child(rhythm_game_instance)
		rhythm_game_instance.disable()
		rhythm_game_instance.hide()
		is_rhythm_game_open = false
		escape_rhythm_game()
	else: #opening
		$HUD/DialogBox.visible = false
		last_rhythm_score = rhythm_game_instance.get_score()
		
		rhythm_game_instance.show()
		rhythm_game_instance.enable()
		is_rhythm_game_open = true
		


func apply_movement(amount) -> void:
	
	velocity += amount
	velocity = velocity.limit_length(MAX_SPEED)

@rpc("any_peer")
func sync_animation(state, blend_position) -> void:
	state_machine.travel(animTree_state_keys[state])
	animationTree.set(blend_pos_paths[state], blend_position)


func animate() -> void:
	
	state_machine.travel(animTree_state_keys[state])
	animationTree.set(blend_pos_paths[state], blend_position)

	#print("auth", is_multiplayer_authority(), multiplayer.get_unique_id())
	sync_animation.rpc(state, blend_position)



func falloff_curve():
	var closest = min($Metronome.time_left, (60.0 / bpm) - $Metronome.time_left)
	#print("Closest:", closest)
	var percentage = 1 - closest / ((60.0 / bpm) / 2)
	#print("Percentage:", percentage)
	var extra_damage = pow(percentage, 2)
	#print("Extra Damage:", extra_damage)

	return extra_damage

var is_alive = true

func respawn() -> void:
	$HealthComponent.visible = false
	$AnimatedSprite2D.visible = false
	$HUD/Stats/Respawning.visible = true
	is_alive = false
	escape_rhythm_game();
	rhythm_game_instance.is_dead()

	var tween = create_tween()
	tween.tween_property(self, "global_position", respawn_position, player_level * 2 + 8)
	await tween.finished

	$AnimatedSprite2D.modulate.a = 0
	$AnimatedSprite2D.visible = true
	var alpha_tween = create_tween()
	alpha_tween.tween_property($AnimatedSprite2D, "modulate:a", 1.0, 0.5)
	await alpha_tween.finished


	# Restore player
	$HUD/Stats/Respawning.visible = false
	rhythm_game_instance.is_alive()


	$HealthComponent.reset_health()
	$HealthComponent.visible = true
	is_alive = true

func _on_health_component_health_destroyed() -> void:
	respawn()

extends CharacterBody2D

class_name Player

@export var bpm = 175
@export var damage = 10
@export var attack_speed = .35
@export var team: Team
@export var respawn_position: Vector2
@onready var rhythm_game_scene = preload("res://rhythm game/scenes/background.tscn");
@export var game_difficulty: Difficulty
@export var can_use_nexus: bool

var player_level = 0
var minion_level = 0
enum Difficulty {EASY = 0,MEDIUM = 1, HARD = 2}
enum Team {BLUE = 0, RED = 1}

var player_powerups = {
	"freeze": 0,
	"damage_powerup": 0
}
var rhythm_game_instance= null
var powerups = ["freeze", "damage_powerup"]


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
	$Metronome.wait_time = 0.25
	cycle_duration = 2 * $Metronome.wait_time # Full cycle duration (1 second)
	frame_duration = cycle_duration / (total_metronome_frames - 1) # 1/12 ≈ 0.0833s
	$Metronome.start()
	$Slice/SliceAnimation.frame = 4
	$HealthComponent.red = team == Team.RED
	rhythm_game_instance = rhythm_game_scene.instantiate()
	rhythm_game_instance.set_difficulty(game_difficulty)
	$RhythmLayer1.add_child(rhythm_game_instance)
	
	rhythm_game_instance.hide()
	rhythm_game_instance.disable()
	Signals.TowerDestroyed.connect(on_tower_destroyed)

	
	old_collision_size = $Slice/SliceArea/CollisionShape2D.shape.size
	if team == Team.RED:
		print("team", team)
		respawn_position = Vector2(651, 3379)
	else:
		respawn_position = Vector2(3401, 600)

	print("respawn pos", respawn_position, team)
	$Stats.hide()
	$HUD.hide()
	
	$MultiplayerSynchronizer.set_multiplayer_authority(str(name).to_int())
	if $MultiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():

		camera.make_current()
		$Stats.show()
		$HUD.show()
	
	if "--server" in OS.get_cmdline_args():
		camera.make_current()

func show_tooltip(msg:String):
	print("[player.gd]","show tooltip")
	$Stats/ToolTip.text = msg
	$Stats/ToolTip.show()
func hide_tooltip():
	print($Stats/Tooltip)
	$Stats/ToolTip.hide()
	
	
func move(delta):
	if not $MultiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
		return
	print('moving')
	if is_rhythm_game_open:
		state = IDLE
		velocity = Vector2.ZERO
		return
	var input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if velocity and Input.is_action_just_pressed("Dash") and not $Stats/Respawning.visible:
		$DashSound.play()
		start_dash.rpc()
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
	$Stats/ManaBar.set_manabar(score)
	
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
func show_victory():
	print("showing victory", team)

	var banner = $"/root/Main/BannerLayer/Banner"
	banner.texture = win_banner
	banner.modulate.a = 0
	banner.show()

	var fade_in = banner.create_tween()
	fade_in.tween_property(banner, "modulate:a", 1, .5)
	await fade_in.finished
	await get_tree().create_timer(2).timeout
	#var scene = load("res://map/game_win.tscn").instantiate()
	var scene = load("res://map/game_win.tscn").instantiate()
	get_tree().root.add_child(scene)
	get_tree().current_scene.queue_free()
	#get_tree().current_scene.change_scene_to_file("res://map/game_win.tscn")

func show_defeat():
	print("showing defeat", team)
	var banner = $"/root/Main/BannerLayer/Banner"
	banner.texture = lose_banner
	banner.modulate.a = 0
	banner.show()

	var fade_in = banner.create_tween()
	fade_in.tween_property(banner, "modulate:a", 1, .5)
	await fade_in.finished
	await get_tree().create_timer(2).timeout
	#get_tree().current_scene.change_scene_to_file("res://map/game_over.tscn")
	var scene = load("res://map/game_win.tscn").instantiate()
	get_tree().root.add_child(scene)
	get_tree().current_scene.queue_free()
	#var scene = load("res://map/game_over.tscn").instantiate()
	#get_tree().change_scene_to(scene)


var red_score = 0
var blue_score = 0
func on_tower_destroyed(tower_team: Team, pos: Vector2):
	if multiplayer.is_server():
		return
	print("team", team, red_score, blue_score)
	if tower_team == Team.RED:
		red_score += 1
	else:
		blue_score += 1
	if red_score == 3:
		# Notify all players
		if team == Team.RED:
			show_defeat()
		else:
			show_victory()
	elif blue_score == 3:
		if team == Team.BLUE:
			show_defeat()
		else:
			show_victory()
			
func _on_metronome_timeout():
	beat_half_count += 1

func _process(delta: float) -> void:
	$Stats/Metronome.text = "metronome: " + str($Metronome.time_left)
	
	var elapsed_in_cycle = (beat_half_count % 2) * $Metronome.wait_time + ($Metronome.wait_time - $Metronome.time_left)
	var current_frame = int(round(elapsed_in_cycle / frame_duration))
	
	if abs(elapsed_in_cycle - 0.5) < 0.01:
		current_frame = 6
	elif abs(elapsed_in_cycle - 1.0) < 0.01:
		current_frame = 12
	
	$Stats/MetronomeContainer/MetronomeAnimation.frame = current_frame % total_metronome_frames

	if $Stats/MetronomeContainer/MetronomeAnimation.frame in centered_frames:
		print("fall off", falloff_curve(), " ", $Stats/MetronomeContainer/MetronomeAnimation.frame)
		var tween = create_tween()
		tween.tween_property($Stats/MetronomeContainer/MetronomeAnimation, "modulate", Color(2, 2, 2, 1), 0.1)
		tween.tween_property($Stats/MetronomeContainer/MetronomeAnimation, "modulate", Color(1, 1, 1, 1), 0.1)

func escape_rhythm_game():
	if is_instance_valid(rhythm_game_instance):
		#$RhythmLayer1.remove_child(rhythm_game_instance)
		
		var score = rhythm_game_instance.get_score()
		rhythm_game_instance.reset_score()
		current_score = min(current_score + int(score / 3000), 300)
		update_mana(current_score)
		is_rhythm_game_open = false

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

var last_combo = 0

func upgrade_player() -> void:
	damage = damage + 1
	$HealthComponent.increase_max_health(20)
func _physics_process(delta: float) -> void:
	if $MultiplayerSynchronizer.is_multiplayer_authority():
		if is_rhythm_game_open:
			var combo = rhythm_game_instance.get_combo()
			if combo and not combo % 10 and combo > last_combo:
				var rand_powerup = powerups[randi_range(0, len(powerups) - 1)]
				player_powerups[rand_powerup] += 1
			last_combo = combo
			
			var score = rhythm_game_instance.get_score()
			var tmp_score = min(current_score + int(score / 3000), 300)
			update_mana(tmp_score)
		if is_dashing:
			dash_timer -= delta
			if dash_timer <= 0:
				is_dashing = false
				sync_is_dashing = false
				#self.collision_mask |= (1 << 2)

		if Input.is_action_just_pressed("toggle_rhythm_game") and $HealthComponent.currentHealth > 0:
			$DashSound.play()
			handle_rhythm_callback()
		if current_score >= 10:
			if Input.is_action_just_pressed("Dispatch_Top"):
				current_score -= 10
				request_wave_spawn.rpc(0, 3, team,minion_level)
				update_mana(current_score)
				
			if Input.is_action_just_pressed("Dispatch_Mid"):
				current_score -= 10
				request_wave_spawn.rpc(1, 3, team,minion_level)
				update_mana(current_score)

			if Input.is_action_just_pressed("Dispatch_Low"):
				current_score -= 10
				request_wave_spawn.rpc(2, 3, team,minion_level)
				update_mana(current_score)
		if Input.is_action_just_pressed("freeze") and current_score >= 250:
			current_score -= 250
			update_mana(current_score)
			print("[player.gd]freeze")
			
			LaneManager.freeze_current_enemies.rpc(0, team)
			LaneManager.freeze_current_enemies.rpc(1, team)
			LaneManager.freeze_current_enemies.rpc(2, team)


		if Input.is_action_just_pressed("damage_powerup") and current_score >= 250:
			print("damage")
			current_score -= 250
			
			LaneManager.damage_powerup.rpc(team)
			
		if Input.is_action_just_pressed("Attack"):
			if $HealthComponent.currentHealth <= 0 or last_attack < attack_speed:
				return
			
			last_attack = 0

			play_slice_anim.rpc(global_position.angle_to_point(get_global_mouse_position()))

			var foundAttack = false

			for body in $Slice/SliceArea.get_overlapping_bodies():
				if body != self and (body is Minion or body is Player) and body.team != team:
					if body.has_node("HealthComponent"):
						foundAttack = true
						body.get_node("HealthComponent").decrease_health.rpc((damage + player_level) + (damage + player_level) * falloff_curve())
						if body.get_node("HealthComponent").get_current_health() <= 0:
							
							$Stats/ManaBar.increase_mana(5)
			
			for body in $Slice/SliceArea.get_overlapping_areas():
				if body is Tower and body.team != team:
					if body.has_node("HealthComponent"):
						foundAttack = true
						body.get_node("HealthComponent").decrease_health.rpc(damage + damage * falloff_curve())
			for body in $Slice/SliceArea.get_overlapping_areas():
				if body is Nexus and body.team != team:
					print("[player.gd]","nexus hit!")
					if body.has_node("HealthComponent"):
						foundAttack = true
						body.get_node("HealthComponent").decrease_health.rpc(damage + damage * falloff_curve())
			if foundAttack:
				var floating_text = floating_text_scene.instantiate()
				floating_text.text = str(round(damage + damage * falloff_curve()))
				floating_text.critical = falloff_curve()
				floating_text.rotation = deg_to_rad(randf_range(-10, 10))
				$Stats/DamagePosition.add_child(floating_text)
		last_attack += delta
		move(delta)
		if Input.is_action_just_pressed("upgrade_minions"):
			print('s')
			if current_score >=100 and can_use_nexus:
				minion_level += 1
				current_score -= 100
				update_mana(current_score)
		if Input.is_action_just_pressed("upgrade_player"):
			if current_score >= 100 and can_use_nexus:
				player_level += 1
				current_score -= 100
				update_mana(current_score)
				
			
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

func get_minimap():
	return $HUD/Minimap

func handle_rhythm_callback():
	if is_rhythm_game_open:
		#$RhythmLayer1.remove_child(rhythm_game_instance)
		rhythm_game_instance.disable()
		rhythm_game_instance.hide()
		is_rhythm_game_open = false
		escape_rhythm_game()
	else:
		
	
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

	print("auth", is_multiplayer_authority(), multiplayer.get_unique_id())
	sync_animation.rpc(state, blend_position)



func falloff_curve():
	var closest = min($Metronome.time_left, (60.0 / bpm) - $Metronome.time_left)
	print("Closest:", closest)
	var percentage = 1 - closest / ((60.0 / bpm) / 2)
	print("Percentage:", percentage)
	var extra_damage = pow(percentage, 2)
	print("Extra Damage:", extra_damage)

	return extra_damage

func respawn() -> void:
	$HealthComponent.visible = false
	$AnimatedSprite2D.visible = false
	$CollisionShape2D.disabled = true
	$Stats/Respawning.visible = true
	escape_rhythm_game();

	var tween = create_tween()
	tween.tween_property(self, "global_position", respawn_position, 4.5)
	await tween.finished

	$AnimatedSprite2D.modulate.a = 0
	$AnimatedSprite2D.visible = true
	var alpha_tween = create_tween()
	alpha_tween.tween_property($AnimatedSprite2D, "modulate:a", 1.0, 0.5)
	await alpha_tween.finished

	# Restore player
	$Stats/Respawning.visible = false

	$HealthComponent.reset_health()
	$HealthComponent.visible = true

	$CollisionShape2D.disabled = false

func _on_health_component_health_destroyed() -> void:
	respawn()

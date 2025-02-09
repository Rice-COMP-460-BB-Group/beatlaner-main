extends CharacterBody2D

class_name Player

@export var bpm = 175
@export var damage = 10
@export var attack_speed = .35
@export var team: Team
@export var respawn_position: Vector2

enum Team {BLUE = 0, RED = 1}

var last_attack = attack_speed

const floating_text_scene = preload("res://player/floating_text.tscn")
const ACCELERATION = 1000
signal wave_request(pos: int, size: int)
const FRICTION = 10000

const MAX_SPEED = 180
const DASH_SPEED = 5000

var dash_timer = 0.0
var is_dashing = false
enum {IDLE,WALK}

var state = IDLE
var is_rhythm_game_open = false
@onready var animationTree = $AnimationTree
@onready var weapon = $Weapon
@onready var state_machine = animationTree["parameters/playback"]
@onready var camera = $Camera2D as Camera2D

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
	$Metronome.wait_time = 0.5
	cycle_duration = 2 * $Metronome.wait_time # Full cycle duration (1 second)
	frame_duration = cycle_duration / (total_metronome_frames - 1) # 1/12 ≈ 0.0833s
	$Metronome.start()
	$Slice/SliceAnimation.frame = 4
	$HealthComponent.red = team == Team.RED
	
	

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
	if $MultiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id() and not multiplayer.is_server():

		camera.make_current()
		$Stats.show()
		$HUD.show()

func move(delta):
	if not $MultiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
		return
	print('moving')
	if is_rhythm_game_open:
		state = IDLE
		velocity = Vector2.ZERO
		return
	var input_vector = Input.get_vector("move_left","move_right","move_up","move_down")
	if Input.is_action_just_pressed("Dash"):
		print('dashing')
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
			self.collision_mask = (self.collision_mask & ~(1 << 2))
			create_afterimage()
	#print("new collision layer", self.collision_layer)
		

func update_mana(score: int):
	$Stats/ManaBar.set_manabar(score)
	
var beat_half_count := 0
var total_metronome_frames := 13
const centered_frames := [0, 6]
var half_beat_duration: float
var frame_duration: float
var cycle_duration: float


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
		var score = rhythm_game_instance.get_score()
		print("rhythm score", score)
		current_score = min(current_score + int(score / 3000), 300)
		$RhythmLayer1.remove_child(rhythm_game_instance)
		is_rhythm_game_open = false
		update_mana(current_score)
func create_afterimage():
	var jump_duration = 0.5  # How long the jump lasts (adjust as needed)
	var num_afterimages = 3  # Number of afterimages you want to create
	var interval = jump_duration / num_afterimages  # Time between afterimages during jump

	var base_interval = 0.05  # Adjust for how frequently afterimages appear

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
		var fade_duration = 0.1  # Adjusted timing formula

		var tween = afterimage.create_tween()
		tween.tween_property(afterimage, "modulate:a", 0, fade_duration)

		await tween.finished
		afterimage.queue_free()
		
@rpc("any_peer", "call_local", "reliable")
func request_wave_spawn(pos: int, size: int, team: bool):
	if multiplayer.is_server():
		LaneManager.wave_request(pos, size, team)


func _physics_process(delta: float) -> void:
	if $MultiplayerSynchronizer.is_multiplayer_authority():

		if is_dashing:
			dash_timer -= delta
			if dash_timer <= 0:
				is_dashing = false
				sync_is_dashing = false
				self.collision_mask |= (1 << 2)

		if Input.is_action_just_pressed("toggle_rhythm_game") and $HealthComponent.currentHealth > 0:
			handle_rhythm_callback()
		if current_score >= 10:
			if Input.is_action_just_pressed("Dispatch_Top"):
				current_score -= 10
				request_wave_spawn.rpc(0, 5, team)
				update_mana(current_score)
				
			if Input.is_action_just_pressed("Dispatch_Mid"):
				current_score -= 10
				request_wave_spawn.rpc(1, 5, team)
				update_mana(current_score)

			if Input.is_action_just_pressed("Dispatch_Low") :
				current_score -= 10
				request_wave_spawn.rpc(2, 5, team)
				update_mana(current_score)
				
		if Input.is_action_just_pressed("Attack"):
			if $HealthComponent.currentHealth <= 0 or last_attack < attack_speed:
				return
			
			last_attack = 0

			var angle_to_cursor = global_position.angle_to_point(get_global_mouse_position())
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


			var foundAttack = false

			for body in $Slice/SliceArea.get_overlapping_bodies():
				if body != self and (body is Minion or body is Player) and body.team != team:
					if body.has_node("HealthComponent"):
						foundAttack = true
						body.get_node("HealthComponent").decrease_health(damage + damage * falloff_curve())
			
			for body in $Slice/SliceArea.get_overlapping_areas():
				if body is Tower and body.team != team:
					if body.has_node("HealthComponent"):
						foundAttack = true
						body.get_node("HealthComponent").decrease_health(damage + damage * falloff_curve())
			
			if foundAttack:
				var floating_text = floating_text_scene.instantiate()
				floating_text.text = str(round(damage + damage * falloff_curve()))
				floating_text.critical = falloff_curve()
				floating_text.rotation = deg_to_rad(randf_range(-10, 10))
				$Stats/DamagePosition.add_child(floating_text)
		last_attack += delta
		move(delta)
		
		animate()
	else:
		$AnimatedSprite2D.animation = "IdleRight"

func get_minimap():
	return $HUD/Minimap

func handle_rhythm_callback():
	if is_rhythm_game_open:
		$RhythmLayer1.remove_child(rhythm_game_instance)
		is_rhythm_game_open = false
		escape_rhythm_game()
	else:
		var rhythm_game_scene = load("res://rhythm game/scenes/background.tscn")
		rhythm_game_instance = rhythm_game_scene.instantiate()
	
		$RhythmLayer1.add_child(rhythm_game_instance)
		is_rhythm_game_open = true
		
func apply_friction(amount) -> void:
	
	if velocity.length() > amount:
		velocity -= velocity.normalized() * amount
	else:
		velocity = Vector2.ZERO

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
var rhythm_game_instance
func OpenRhythmGame(tmp_tower_type: String, tower):
	if $RhythmLayer1.get_children():
		$RhythmLayer1.remove_child(rhythm_game_instance)
		return
	
	var rhythm_game_scene = load("res://rhythm game/scenes/background.tscn")
	rhythm_game_instance = rhythm_game_scene.instantiate()
	
	$RhythmLayer1.add_child(rhythm_game_instance)

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

extends CharacterBody2D


const ACCELERATION = 1000
signal wave_request(pos: int, size: int)
const FRICTION = 10000

const MAX_SPEED = 180

enum {IDLE,WALK}

var state = IDLE
var is_rhythm_game_open = false
@onready var animationTree = $AnimationTree

@onready var state_machine = animationTree["parameters/playback"]


var blend_position : Vector2 = Vector2.ZERO
var blend_pos_paths = ["parameters/Idle/id_BlendSpace2D/blend_position","parameters/Moving/BlendSpace2D/blend_position"]
var current_score = 0
var animTree_state_keys = [
	"Idle","Moving"
]

func move(delta):
	if is_rhythm_game_open:
		state = IDLE
		velocity = Vector2.ZERO
		return
	var input_vector = Input.get_vector("move_left","move_right","move_up","move_down")
	if input_vector == Vector2.ZERO:
		state = IDLE
		velocity = Vector2.ZERO
	else:
		input_vector = input_vector.normalized()
		state = WALK
		apply_movement(input_vector * MAX_SPEED)
		blend_position = input_vector
	move_and_slide()

func update_mana(score: int):
	$Stats/Mana.text = "Mana:" + str(current_score)
	
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("escape rhythm game"):
		if is_instance_valid(rhythm_game_instance):
			
			var score = rhythm_game_instance.get_score()
			current_score += int(score / 100)
			$RhythmLayer1.remove_child(rhythm_game_instance)
			is_rhythm_game_open = false
			update_mana(current_score)
	if Input.is_action_just_pressed("toggle_rhythm_game"):
		handle_rhythm_callback()
	
	if Input.is_action_just_pressed("Dispatch_Top") and current_score > 100:
		current_score -= 100
		wave_request.emit(0,10)
		update_mana(current_score)
		
	if Input.is_action_just_pressed("Dispatch_Mid") and current_score > 100:
		current_score -= 100
		wave_request.emit(1,10)
		update_mana(current_score)
		print("s")
	if Input.is_action_just_pressed("Dispatch_Low") and current_score > 100:
		current_score -= 100
		wave_request.emit(2,10)
		update_mana(current_score)
		
		
	move(delta)
	
	animate()


func handle_rhythm_callback():
	if is_rhythm_game_open:
		$RhythmLayer1.remove_child(rhythm_game_instance)
		is_rhythm_game_open = false
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
	
		
func animate() -> void:
	
	state_machine.travel(animTree_state_keys[state])
	animationTree.set(blend_pos_paths[state],blend_position)
var rhythm_game_instance
func OpenRhythmGame(tmp_tower_type: String, tower):
	if $RhythmLayer1.get_children():
		$RhythmLayer1.remove_child(rhythm_game_instance)
		return
	
	var rhythm_game_scene = load("res://rhythm game/scenes/background.tscn")
	rhythm_game_instance = rhythm_game_scene.instantiate()
	
	$RhythmLayer1.add_child(rhythm_game_instance)

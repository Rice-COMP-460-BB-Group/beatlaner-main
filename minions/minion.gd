extends CharacterBody2D

@export var target: Node2D

@export var hp: int

@export var team: int

var speed = 300

var accel = 5


@onready var navigation_agent_2d: NavigationAgent2D = $NavigationHandler/NavigationAgent2D

# Called when the node enters the scene tree for the first time.
 # Replace with function body.
var movement_speed = 50

# Called every frame. 'delta' is the elapsed time since the previous frame.
@warning_ignore("unused_parameter")
func _physics_process(delta: float):
	navigation_agent_2d.target_position = target.position
	
	
	
	var current_agent_position = global_position
	var next_path_position = navigation_agent_2d.get_next_path_position()
	var new_velocity = current_agent_position.direction_to(next_path_position) * movement_speed
	
	if navigation_agent_2d.is_navigation_finished():
		return
	
	if navigation_agent_2d.avoidance_enabled:
		navigation_agent_2d.set_velocity(new_velocity)
	else:
		_on_navigation_agent_2d_velocity_computed(new_velocity)
	move_and_slide()


func _on_timer_timeout() -> void:
	@warning_ignore("standalone_expression")
	navigation_agent_2d.target_position
	pass # Replace with function body.


func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity

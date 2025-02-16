extends Area2D
class_name Nexus
enum Team {BLUE,RED}
var team = Team.BLUE
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func set_team(new_team:Team):
	team = new_team

func get_team()-> Team:
	return team
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_detection_area_body_entered(body: Node2D) -> void:
	print("[nexus.gd]","body entered")
	if body is Player:
		print("[nexus.gd]","hey player")
		print("[nexus.gd]",body.team,"team",team)
		if body.team == team:
			 
			body.can_use_nexus = true
			body.show_tooltip("M:upgrade minions\nN:upgrade yourself")


func _on_detection_area_body_exited(body: Node2D) -> void:
	print("[nexus.gd]","body exited")
	if body is Player:
		if body.team == team:
			body.can_use_nexus = false
			body.hide_tooltip()

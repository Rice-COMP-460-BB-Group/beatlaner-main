extends Area2D
var powerups = ["freeze", "damage_powerup", "heal"]

var isLaneNode = false


func _ready():
	add_to_group("Powerup")
	var old_scale = scale
	scale = Vector2.ZERO
	var tween = create_tween()
	tween.tween_property(self, "scale", old_scale, .75).set_trans(Tween.TRANS_SINE)

func _on_body_entered(body):
	if multiplayer.is_server():
		if body.is_in_group("Player"):
			var rand_powerup = powerups[randi_range(0, len(powerups) - 1)]
			print('rand powerup', rand_powerup)
			body.add_powerup.rpc(rand_powerup)
			rpc("destroy_powerup")

@rpc("any_peer", "call_local")
func destroy_powerup():
	queue_free()

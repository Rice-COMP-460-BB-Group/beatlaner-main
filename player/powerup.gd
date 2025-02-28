extends Area2D
var powerups = ["freeze", "damage_powerup"]

var isLaneNode = false


func _ready():
	add_to_group("Powerup")

func _on_body_entered(body):
	print('collided')
	if multiplayer.is_server():
		print('collided')
		if body.is_in_group("Player"):
			print('is player')
			var rand_powerup = powerups[randi_range(0, len(powerups) - 1)]
			body.add_powerup.rpc(rand_powerup)
		rpc("destroy_powerup")

@rpc("any_peer", "call_local")
func destroy_powerup():
	print("powerup destroyed")
	queue_free()

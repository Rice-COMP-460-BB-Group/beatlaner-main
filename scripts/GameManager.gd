extends Node

var Players = {}
var server_pid = -1

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().set_auto_accept_quit(false)

func cleanup():
	if GameManager.server_pid > 0:
		OS.kill(GameManager.server_pid)
		GameManager.server_pid = -1

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		print("closing")
		cleanup()
		get_tree().quit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

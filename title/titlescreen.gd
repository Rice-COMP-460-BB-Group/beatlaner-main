extends Control

@export var Address = "127.0.0.1"
@export var port = 8910
var peer


func _ready():
	#$VBoxContainer/Start.grab_focus()
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)

func _on_start_pressed() -> void:
	print('got pressed')
	StartGame.rpc()


func _on_exit_pressed() -> void:
	$Confirm.play()
	await $Confirm.finished
	get_tree().quit()


func _on_button_focus_entered() -> void:
	$Focus.play()




func peer_connected(id):
	print("Player Connected " + str(id))
	
# this get called on the server and clients
func peer_disconnected(id):
	print("Player Disconnected " + str(id))
	GameManager.Players.erase(id)
	var players = get_tree().get_nodes_in_group("Player")
	for i in players:
		if i.name == str(id):
			i.queue_free()
# called only from clients
func connected_to_server():
	print("connected To Sever!")
	SendPlayerInformation.rpc_id(1, "", multiplayer.get_unique_id())

# called only from clients
func connection_failed():
	print("Couldnt Connect")

@rpc("any_peer")
func SendPlayerInformation(name, id):
	if !GameManager.Players.has(id):
		GameManager.Players[id] ={
			"name" : name,
			"id" : id,
			"score": 0
		}
	
	if multiplayer.is_server():
		for i in GameManager.Players:
			SendPlayerInformation.rpc(GameManager.Players[i].name, i)

@rpc("any_peer","call_local")
func StartGame():
	$Confirm.play()
	await $Confirm.finished
	#get_tree().change_scene_to_file.bind("res://main/Main.tscn").call_deferred()
	print("players, ", GameManager.Players)
	var scene = load("res://main/Main.tscn").instantiate()
	get_tree().root.add_child(scene)
	#self.hide()
	
	
func _on_host_button_down():
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, 2)
	if error != OK:
		print("cannot host: " + error)
		return
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	
	multiplayer.set_multiplayer_peer(peer)
	print("Waiting for players")
	SendPlayerInformation("", multiplayer.get_unique_id())
	pass # Replace with function body.


func _on_join_button_down():
	peer = ENetMultiplayerPeer.new()
	peer.create_client(Address, port)
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)	
	
	pass # Replace with function body.


func _on_start_game_button_down():
	StartGame.rpc()
	pass # Replace with function body.

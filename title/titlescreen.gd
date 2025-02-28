extends Control

@export var port = 8910
@export var peer = null
var dedicated_server = false

	
func _ready():
	#$VBoxContainer/Start.grab_focus()
	$VBoxContainer/Start.focus_mode = Control.FOCUS_NONE
	$VBoxContainer/Join.focus_mode = Control.FOCUS_NONE
	$VBoxContainer/Exit.focus_mode = Control.FOCUS_NONE
	$SelectHost.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$SelectJoin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$SelectExit.mouse_filter = Control.MOUSE_FILTER_IGNORE
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)

	if "--server" in OS.get_cmdline_args():
		dedicated_server = true
		DisplayServer.window_set_title("Beatlaner Server")
		hostGame()
		$VBoxContainer/Start.text = "Start"

	if "--auto" in OS.get_cmdline_args() and !dedicated_server:
		peer = ENetMultiplayerPeer.new()
		peer.create_client("localhost", port)
		peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
		multiplayer.set_multiplayer_peer(peer)

		print("auto connecting to server...")

func _on_start_pressed() -> void:
	print('got pressed')
	# nobody has joined yet
	if peer == null:
		hostGame()
		if !dedicated_server:
			SendPlayerInformation("", multiplayer.get_unique_id())
		$VBoxContainer/Start.text = "Start"
	else:
		$Background.stop()
		StartGame.rpc()
	# StartGame.rpc()


func _on_exit_pressed() -> void:
	$Confirm.play()
	await $Confirm.finished
	get_tree().quit()


func _on_button_focus_entered() -> void:
	$Focus.play()


func peer_connected(id):
	if multiplayer.is_server():
		print("Player Connected " + str(id))

		if "--auto" in OS.get_cmdline_args():
			print("auto starting...")
			$Background.stop()
			StartGame.rpc()
	
# this get called on the server and clients
func peer_disconnected(id):
	print("Player Disconnected " + str(id))
	GameManager.Players.erase(id)
	var players = get_tree().get_nodes_in_group("Player")
	for i in players:
		if i.name == str(id):
			i.queue_free()
			
	
	$ConnectedCount.text = "%s / 2 Players Connected" % (GameManager.Players.size())
# called only from clients
func connected_to_server():
	print("connected To Sever!")
	SendPlayerInformation.rpc_id(1, "", multiplayer.get_unique_id())
	$VBoxContainer/Join.text = "Disconnect"
	$VBoxContainer/Start.disabled = true

# called only from clients
func connection_failed():
	print("Connection Failed!")
	$ErrorDialog.dialog_text = "Failed to connect to server %s" % ($JoinIP/VBoxContainer/IPInput.text)
	$ErrorDialog.popup()

@rpc("any_peer")
func SendPlayerInformation(name, id):
	if GameManager.Players.has(id):
		return
	if !GameManager.Players.has(id):
		GameManager.Players[id] = {
			"name": name,
			"id": id,
			"score": 0
		}
	
	$ConnectedCount.text = "%s / 2 Players Connected" % (GameManager.Players.size())
	if multiplayer.is_server():
		for i in GameManager.Players:
			SendPlayerInformation.rpc(GameManager.Players[i].name, i)

@rpc("any_peer", "call_local")
func StartGame():
	if GameManager.Players.size() < 2 && !("--auto" in OS.get_cmdline_args()):
		print("Not enough players to start!")
		$ErrorDialog.dialog_text = "Not enough players to start!"
		$ErrorDialog.popup()
		return # Stop if there are less than 2 players
	$Confirm.play()
	await $Confirm.finished
	#get_tree().change_scene_to_file.bind("res://main/Main.tscn").call_deferred()
	print("players, ", GameManager.Players)
	$Background.stop()

	var scene
	if "--auto" in OS.get_cmdline_args():
		scene = load("res://main/Main.tscn").instantiate()
		scene.current_difficulty = 2 # set to easy difficulty
	else:
		scene = load("res://title/difficulty_selector.tscn").instantiate()
	
		var lowest_id = multiplayer.get_unique_id()
		for player_id in GameManager.Players.keys():
			if player_id < lowest_id:
				lowest_id = player_id
		if multiplayer.get_unique_id() == lowest_id:
			scene.team = 1
		else:
			scene.team = 0
	self.hide()
	get_tree().root.add_child(scene)
	#self.hide()
	
	
func hostGame():
	$ConnectedCount.show()
	$ConnectedCount.text = "%s / 2 Players Connected" % (GameManager.Players.size())
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, 4)
	if error != OK:
		print("cannot host: " + str(error))
		return
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	
	multiplayer.set_multiplayer_peer(peer)
	print("Waiting For Players!")
	
func _on_host_button_down():
	hostGame()
	SendPlayerInformation("", multiplayer.get_unique_id())
	pass # Replace with function body.


func _on_join_pressed():
	if peer and peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED:
		peer.close()
		multiplayer.set_multiplayer_peer(null)
		$VBoxContainer/Join.text = "Join"
		$VBoxContainer/Start.disabled = false
		return
	$JoinIP.show()

func _on_join_ip_confirmed() -> void:
	if peer and peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED:
		print("Already connected!")
		return

	peer = ENetMultiplayerPeer.new()
	var ip = $JoinIP/VBoxContainer/IPInput.text
	if ip.is_empty():
		ip = $JoinIP/VBoxContainer/IPInput.placeholder_text
	peer.create_client(ip, port)
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)
	
	pass # Replace with function body.


func _on_start_mouse_entered() -> void:
	$SelectHost.visible = true
	pass # Replace with function body.


func _on_join_mouse_entered() -> void:
	$SelectJoin.visible = true


func _on_exit_mouse_entered() -> void:
	$SelectExit.visible = true


func _on_start_mouse_exited() -> void:
	$SelectHost.visible = false


func _on_join_mouse_exited() -> void:
	$SelectJoin.visible = false


func _on_exit_mouse_exited() -> void:
	$SelectExit.visible = false

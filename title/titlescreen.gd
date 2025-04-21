extends Control

@export var port = 8910
@export var peer = null
var dedicated_server = false

func _ready():
	var resultsgame = get_tree().root.get_node_or_null("ResultsScreen")
	if resultsgame:
		resultsgame.queue_free()
	if "--server" not in OS.get_cmdline_args():
		if OS.get_name() == "Windows":
			var output = []
			OS.execute("taskkill", ["/F", "/IM", OS.get_executable_path().get_file(), "/FI", "WINDOWTITLE eq Beatlaner Server"], output)
		elif OS.get_name() == "macOS" or OS.get_name() == "Linux":
			var output = []
			var executable_name = OS.get_executable_path().get_file()
			
			OS.execute("sh", ["-c", "ps aux | grep '" + executable_name + "' | grep -- '--server' | grep -v grep"], output)
			for line in output:
				if line.strip_edges() != "":
					var parts = line.strip_edges().split(" ", false)
					var pid = ""
					
					var count = 0
					for part in parts:
						if part != "":
							count += 1
							if count == 2:
								pid = part
								break
					
					if pid != "":
						print("Killing process: ", pid)
						var kill_output = []
						OS.execute("kill", ["-9", pid], kill_output)
						print("Kill result: ", kill_output)
						break
	
	# Animation for title screen elements
	animate_ui_elements()
	
	# Set up focus for button navigation
	$TitleContainer/ButtonsPanel/VBoxContainer/SinglePlayer.grab_focus()
	
	$TitleContainer/TopBar/HBoxContainer/Exit.focus_mode = Control.FOCUS_NONE
	$TitleContainer/TopBar/HBoxContainer/Settings.focus_mode = Control.FOCUS_NONE
	$TitleContainer/TopBar/HBoxContainer/TutorialButton.focus_mode = Control.FOCUS_NONE
	$TitleContainer/ButtonsPanel/VBoxContainer/SinglePlayer.focus_mode = Control.FOCUS_ALL
	$TitleContainer/ButtonsPanel/VBoxContainer/Start.focus_mode = Control.FOCUS_ALL
	$TitleContainer/ButtonsPanel/VBoxContainer/Join.focus_mode = Control.FOCUS_ALL
	
	# Hide selector elements initially
	$SelectHost.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$SelectJoin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$SelectExit.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$SelectSettings.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	$TitleContainer/ButtonsPanel/ConnectedCount.hide()

	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)

	if "--server" in OS.get_cmdline_args():
		dedicated_server = true
		DisplayServer.window_set_title("Beatlaner Server")
		hostGame()
		$TitleContainer/ButtonsPanel/VBoxContainer/Start.text = "Start"

	if "--auto" in OS.get_cmdline_args() and !dedicated_server:
		peer = ENetMultiplayerPeer.new()
		peer.create_client("localhost", port)
		peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
		multiplayer.set_multiplayer_peer(peer)

		print("auto connecting to server...")

func animate_ui_elements():
	# Logo animation
	var logo = $TitleContainer/LogoContainer/Sprite2D
	logo.modulate.a = 0
	logo.scale = Vector2(3, 3) # Start with larger scale for better animation
	
	var logo_tween = create_tween().set_parallel()
	logo_tween.tween_property(logo, "modulate:a", 1.0, 1.0).set_ease(Tween.EASE_OUT)
	logo_tween.tween_property(logo, "scale", Vector2(2.5, 2.5), 1.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	
	# Button panel animation
	var buttons_panel = $TitleContainer/ButtonsPanel
	buttons_panel.modulate.a = 0
	buttons_panel.position.y += 50
	
	var panel_tween = create_tween()
	panel_tween.tween_property(buttons_panel, "modulate:a", 1.0, 0.8).set_ease(Tween.EASE_OUT)
	panel_tween.parallel().tween_property(buttons_panel, "position:y", buttons_panel.position.y - 50, 0.8).set_ease(Tween.EASE_OUT)
	
	# Top bar animation
	var top_bar = $TitleContainer/TopBar
	top_bar.modulate.a = 0
	
	var top_bar_tween = create_tween()
	top_bar_tween.tween_property(top_bar, "modulate:a", 1.0, 0.8).set_ease(Tween.EASE_OUT)

func _on_start_pressed() -> void:
	print('got pressed')
	# nobody has joined yet
	if peer == null:
		hostGame()
		if !dedicated_server:
			SendPlayerInformation("", multiplayer.get_unique_id())
		$TitleContainer/ButtonsPanel/VBoxContainer/Start.text = "Start"
	else:
		$Background.stop()
		$TitleContainer/ButtonsPanel/VBoxContainer/Start.disabled = true
		StartGame.rpc()

func _on_exit_pressed() -> void:
	$Confirm.play()
	
	# Create exit animation
	var panel_tween = create_tween().set_parallel()
	panel_tween.tween_property($TitleContainer/ButtonsPanel, "modulate:a", 0.0, 0.5).set_ease(Tween.EASE_IN)
	panel_tween.tween_property($TitleContainer/TopBar, "modulate:a", 0.0, 0.5).set_ease(Tween.EASE_IN)
	panel_tween.tween_property($TitleContainer/LogoContainer/Sprite2D, "modulate:a", 0.0, 0.5).set_ease(Tween.EASE_IN)
	
	await panel_tween.finished
	await $Confirm.finished
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)

func _on_button_focus_entered() -> void:
	$Focus.play()

var connection = 0
func peer_connected(id):
	if multiplayer.is_server():
		print("Player Connected " + str(id))
		connection += 1
		if "--auto" in OS.get_cmdline_args() and (connection >= 2 or !"--cap" in OS.get_cmdline_args()):
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
			
	$TitleContainer/ButtonsPanel/ConnectedCount.text = "%s / 2 Players Connected" % (GameManager.Players.size())
	
# called only from clients
func connected_to_server():
	$TitleContainer/ButtonsPanel/VBoxContainer/Start.disabled = true
	print("connected To Sever!")
	SendPlayerInformation.rpc_id(1, "", multiplayer.get_unique_id())
	$TitleContainer/ButtonsPanel/VBoxContainer/Join.text = "Disconnect"

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
	
	$TitleContainer/ButtonsPanel/ConnectedCount.show()
	$TitleContainer/ButtonsPanel/ConnectedCount.text = "%s / 2 Players Connected" % (GameManager.Players.size())
	if multiplayer.is_server():
		for i in GameManager.Players:
			SendPlayerInformation.rpc(GameManager.Players[i].name, i)

@rpc("any_peer", "call_local")
func StartGame():
	# if cap is enabled, then only 2 players can join
	if GameManager.Players.size() < 2 && !("--auto" in OS.get_cmdline_args()) && !single_player_mode:
		print("Not enough players to start!")
		$ErrorDialog.dialog_text = "Not enough players to start!"
		$ErrorDialog.popup()
		return # Stop if there are less than 2 players
	$Confirm.play()
	
	# Create start game animation
	var panel_tween = create_tween().set_parallel()
	panel_tween.tween_property($TitleContainer/ButtonsPanel, "modulate:a", 0.0, 0.5).set_ease(Tween.EASE_IN)
	panel_tween.tween_property($TitleContainer/TopBar, "modulate:a", 0.0, 0.5).set_ease(Tween.EASE_IN)
	panel_tween.tween_property($BackgroundContainer/"Nature Art", "modulate:a", 0.0, 1.0).set_ease(Tween.EASE_IN)
	
	await panel_tween.finished
	await $Confirm.finished
	$Background.stop()

	var scene
	if "--auto" in OS.get_cmdline_args() or single_player_mode:
		scene = load("res://main/Main.tscn").instantiate()
		scene.current_difficulty = 0 # set to easy difficulty
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
	
func hostGame():
	$TitleContainer/ButtonsPanel/ConnectedCount.show()
	$TitleContainer/ButtonsPanel/ConnectedCount.text = "%s / 2 Players Connected" % (GameManager.Players.size())
	$TitleContainer/ButtonsPanel/VBoxContainer/Join.disabled = true
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

var single_player_mode = false

func _on_single_player_pressed():
	GameManager.cleanup()
		
	var pid = OS.create_process(OS.get_executable_path(), ["--auto", "--server", "--headless"])
	GameManager.server_pid = pid
	get_tree().auto_accept_quit = false

	single_player_mode = true
	if peer and peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED:
		peer.close()
		multiplayer.set_multiplayer_peer(null)
		$TitleContainer/ButtonsPanel/VBoxContainer/Join.text = "Join"
		$TitleContainer/ButtonsPanel/VBoxContainer/Start.disabled = false
		return
	
	# Add button press effect
	button_press_effect($TitleContainer/ButtonsPanel/VBoxContainer/SinglePlayer)
	
	peer = ENetMultiplayerPeer.new()
	peer.create_client("localhost", port)
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)

func _on_join_pressed():
	if peer and peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED:
		peer.close()
		multiplayer.set_multiplayer_peer(null)
		$TitleContainer/ButtonsPanel/VBoxContainer/Join.text = "Join"
		$TitleContainer/ButtonsPanel/VBoxContainer/Start.disabled = false
		return
	
	# Add button press effect
	button_press_effect($TitleContainer/ButtonsPanel/VBoxContainer/Join)
	
	$JoinIP.show()

func button_press_effect(button):
	var original_scale = button.scale
	var button_pivot = button.size / 2
	
	# Set the button's pivot to center for proper expansion
	button.set_pivot_offset(button_pivot)
	
	var tween = create_tween()
	tween.tween_property(button, "scale", original_scale * 0.9, 0.1)
	tween.tween_property(button, "scale", original_scale, 0.1)

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

# Mouse hover effects for buttons
func _on_start_mouse_entered() -> void:
	if not $TitleContainer/ButtonsPanel/VBoxContainer/Start.disabled:
		$SelectHost.visible = true
		# Better positioning with improved padding
		$SelectHost.position = Vector2(
			$TitleContainer/ButtonsPanel/VBoxContainer/Start.global_position.x - 45,
			$TitleContainer/ButtonsPanel/VBoxContainer/Start.global_position.y)
		$Focus.play()
		pulse_button($TitleContainer/ButtonsPanel/VBoxContainer/Start)

func _on_join_mouse_entered() -> void:
	if not $TitleContainer/ButtonsPanel/VBoxContainer/Join.disabled:
		$SelectJoin.visible = true
		# Better positioning with improved padding
		$SelectJoin.position = Vector2(
			$TitleContainer/ButtonsPanel/VBoxContainer/Join.global_position.x - 45,
			$TitleContainer/ButtonsPanel/VBoxContainer/Join.global_position.y)
		$Focus.play()
		pulse_button($TitleContainer/ButtonsPanel/VBoxContainer/Join)

func _on_exit_mouse_entered() -> void:
	$SelectExit.visible = true
	$SelectExit.position = Vector2(
		$TitleContainer/TopBar/HBoxContainer/Exit.global_position.x - 15,
		$TitleContainer/TopBar/HBoxContainer/Exit.global_position.y + 20)
	$Focus.play()
	pulse_button($TitleContainer/TopBar/HBoxContainer/Exit)

func _on_single_player_mouse_entered() -> void:
	$SelectHost.visible = true
	# Better positioning with improved padding
	$SelectHost.position = Vector2(
		$TitleContainer/ButtonsPanel/VBoxContainer/SinglePlayer.global_position.x - 45,
		$TitleContainer/ButtonsPanel/VBoxContainer/SinglePlayer.global_position.y)
	$Focus.play()
	pulse_button($TitleContainer/ButtonsPanel/VBoxContainer/SinglePlayer)

func pulse_button(button):
	var original_scale = button.scale
	var button_pivot = button.size / 2
	
	# Set the button's pivot to center for proper expansion
	button.set_pivot_offset(button_pivot)
	
	var tween = create_tween()
	tween.tween_property(button, "scale", original_scale * 1.1, 0.15)
	tween.tween_property(button, "scale", original_scale, 0.15)

func _on_start_mouse_exited() -> void:
	if not $TitleContainer/ButtonsPanel/VBoxContainer/Start.disabled:
		$SelectHost.visible = false

func _on_join_mouse_exited() -> void:
	if not $TitleContainer/ButtonsPanel/VBoxContainer/Join.disabled:
		$SelectJoin.visible = false

func _on_single_player_mouse_exited() -> void:
	$SelectHost.visible = false

func _on_settings_mouse_entered():
	# No outline for settings button - just play the sound and pulse
	$Focus.play()
	pulse_button($TitleContainer/TopBar/HBoxContainer/Settings)

func _on_settings_mouse_exited():
	# Make sure no outline is visible
	$SelectSettings.visible = false

func _on_settings_pressed():
	button_press_effect($TitleContainer/TopBar/HBoxContainer/Settings)
	$KeybindingScreen.show()

func _on_tutorial_button_pressed():
	button_press_effect($TitleContainer/TopBar/HBoxContainer/TutorialButton)
	$Tutorial.show()

# Add a new function for tutorial button mouse entered
func _on_tutorial_button_mouse_entered():
	# No outline for tutorial button - just play the sound and pulse
	$Focus.play()
	pulse_button($TitleContainer/TopBar/HBoxContainer/TutorialButton)

# Add a new function for tutorial button mouse exited
func _on_tutorial_button_mouse_exited():
	pass

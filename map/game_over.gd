extends Control

@export var win: bool = false
# Called when the node enters the scene tree for the first time.

func update_stats_display():
	# Clear the text first

	# Get all stats from MatchStats
	var all_stats = MatchStats.get_all_stats()
	
	var idx = 1
	# Iterate over each player
	for player_id in all_stats.keys():
		var stats_label = get_node("VBoxContainer/Control/HBox/Player" + str(idx) + "StatsLabel")  # Use get_node() to find StatsLabel reliably
		stats_label.text = ""  
		

		var stats_text = "Player %d:\n" % idx  # Header for each player
		
		idx += 1
		# Iterate over each stat for the player
		for stat_name in all_stats[player_id]:
			# Special handling for match_length
			if stat_name == "match_length":
				if player_id == multiplayer.get_unique_id():
					# Get the MatchLength label and update it directly
					var match_length_label = get_node("VBoxContainer/MatchLength")
					if match_length_label != null:
						var total_seconds = all_stats[player_id][stat_name] / 1000  # Convert ms to seconds
						var hours = total_seconds / 3600
						var minutes = (total_seconds % 3600) / 60
						var seconds = total_seconds % 60
						match_length_label.text = "%02d:%02d:%02d" % [hours, minutes, seconds]
						match_length_label.text = str(all_stats[player_id][stat_name])
					else:
						print("MatchLength label not found!")
				continue  # Skip this stat and move to the next one
			if stat_name == "total_damage_dealt":
				stats_text +=  "- %s: %s\n" % str(all_stats[player_id][stat_name]).pad_decimals(2)
			# Add other stats to stats_text
			else:
				stats_text += "- %s: %s\n" % [stat_name, all_stats[player_id][stat_name]]
		
		# Append to the StatsLabel
		stats_label.text += stats_text + "\n"  # Extra line for spacing




func _ready() -> void:
	$"VBoxContainer/Main Menu".grab_focus()
	if not multiplayer.is_server():
		#await get_tree().process_frame
		call_deferred("update_stats_display")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_main_menu_pressed() -> void:
	self.hide()
	get_tree().change_scene_to_file.bind("res://title/titlescreen.tscn").call_deferred()
	#MatchStats.reset_stats()

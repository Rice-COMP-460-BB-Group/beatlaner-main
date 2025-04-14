extends Control

@export var win: bool = false
# Called when the node enters the scene tree for the first time.

var new_stat_name = {
	"player_kill_count": "Player Kills",
	"minion_kill_count": "Minion Kills",
	#"total_damage_dealt": 0,
	#"total_damage_received": 0,
	"death_count": "Death Count",
	#"ability_used_count": 0,
	"osu_highest_combo": "Highest Combo",
	#"osu_notes_hit_count": 0,
	#"osu_average_accuracy": "Osu Accuracy", 
	"minion_spawn_count": "Minion Spawn Count",
	#"match_length": 0
	"mana_generated": "Mana Generated"

}

# total mana generated

func update_stats_display():
	# Clear the text first
	$Winner.text = 'You won!' if multiplayer.get_unique_id() == MatchStats.get_winner() else 'You lost!'
		

	# Get all stats from MatchStats
	var all_stats = MatchStats.get_all_stats()
	print(multiplayer.get_unique_id(), ' all stats', all_stats)
	
	var idx = 1
	# Iterate over each player
	var sorted_keys = all_stats.keys()
	sorted_keys.sort()
	for player_id in sorted_keys:
		var stats_label = %Player1StatsLabel if idx == 1 else %Player2StatsLabel #get_node("Player" + str(idx) + "StatsLabel")  # Use get_node() to find StatsLabel reliably
		stats_label.text = ""  
		
		print('stat label', stats_label)
		

		var stats_text = "Player %d:\n" % idx  # Header for each player
		
		idx += 1

		for stat_name in all_stats[player_id]:
			# Special handling for match_length
			if stat_name == "match_length":
				if player_id == multiplayer.get_unique_id():
					# Get the MatchLength label and update it directly
					var match_length_label = get_node("MatchLength")
					if match_length_label != null:
						var total_seconds = all_stats[player_id][stat_name] / 1000  # Convert ms to seconds
						var hours = total_seconds / 3600
						var minutes = (total_seconds % 3600) / 60
						var seconds = total_seconds % 60
						match_length_label.text = "%02d:%02d:%02d" % [hours, minutes, seconds]
					else:
						print("MatchLength label not found!")
				continue  # Skip this stat and move to the next one
			if stat_name not in new_stat_name:
				continue
			if stat_name == "total_damage_dealt":
				stats_text += "%s: %.2f\n" % [new_stat_name[stat_name], all_stats[player_id][stat_name]]
			# Add other stats to stats_text
			else:
				stats_text += "%s: %s\n" % [new_stat_name[stat_name], all_stats[player_id][stat_name]]
			print('stat name', stat_name, all_stats[player_id][stat_name])
		# Append to the StatsLabel
		stats_label.text += stats_text + "\n"  # Extra line for spacing

func _ready() -> void:
	#if not multiplayer.is_server():
		#await get_tree().process_frame
	call_deferred("update_stats_display")

#
#func _on_main_menu_pressed() -> void:
	#self.hide()
	#get_tree().change_scene_to_file.bind("res://title/titlescreen.tscn").call_deferred()
	##MatchStats.reset_stats()


func _on_exit_pressed() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)

func change_to_scene(scene_path: String):
	var children = get_tree().get_root().get_children()
	var scene = load(scene_path).instantiate()
	get_tree().root.add_child(scene)

	for child in children:
		if child.name == "MatchStats":
			MatchStats.reset_stats()
			continue
		if child.name == "GameManager" or child.name == "Signals":
			if child.name == "GameManager":
				child.Players = {}
			continue
		if child.name == "Titlescreen":
			child.peer = null
		child.call_deferred("queue_free")


func _on_main_menu_pressed() -> void:
	change_to_scene("res://title/titlescreen.tscn")

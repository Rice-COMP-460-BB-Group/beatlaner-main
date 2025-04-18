extends Control

var display_time = 5.0
var buttons_enabled = false
@onready var timer = $CountdownTimer
@onready var progress_bar = $MainContainer/TimerSection/ProgressBar
@onready var timer_value_label = $MainContainer/TimerSection/TimerContainer/TimerValue

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

func update_stats_display():
	# Clear the text first
	$MainContainer/HeaderSection/ResultDisplay/ResultBanner/ResultLabel.text = 'VICTORY' if multiplayer.get_unique_id() == MatchStats.get_winner() else 'DEFEAT'
		

	# Get all stats from MatchStats
	var all_stats = MatchStats.get_all_stats()
	print(multiplayer.get_unique_id(), ' all stats', all_stats)
	
	var idx = 1
	# Iterate over each player
	var sorted_keys = all_stats.keys()
	sorted_keys.sort()
	var second_id = sorted_keys[1]
	$MainContainer/ContentContainer/StatsGrid/Player1KDA.text = str(all_stats[1]["player_kill_count"]) + " / " + str(all_stats[1]["death_count"])
	$MainContainer/ContentContainer/StatsGrid/Player1Mana.text = str(all_stats[1]["mana_generated"])
	$MainContainer/ContentContainer/StatsGrid/Player1Minions.text = str(all_stats[1]["minion_kill_count"])
	$MainContainer/ContentContainer/StatsGrid/Player1Combo.text = str(all_stats[1]["osu_highest_combo"])
	$MainContainer/ContentContainer/StatsGrid/Player1Spawned.text = str(all_stats[1]["minion_spawn_count"])
	var p1title = ""
	# Death-related titles
	if all_stats[1]["death_count"] > 10:
		p1title = "Professional Inter"
	elif all_stats[1]["death_count"] == 0:
		p1title = "Can't touch this"
	
	# Kill/minion-related titles
	if all_stats[1]["minion_kill_count"] > 100:
		p1title = "The Minion Slayer"
	elif all_stats[1]["player_kill_count"] > 5:
		p1title = "Challenger in Training"
	
	# Rhythm game titles
	if all_stats[1]["osu_highest_combo"] > 100:
		p1title = "Missed Life, Not Notes"
	elif all_stats[1]["osu_acc_sum"] > 0 && all_stats[1]["osu_acc_notes_count"] > 0 && (float(all_stats[1]["osu_acc_sum"]) / all_stats[1]["osu_acc_notes_count"]) > 0.9:
		p1title = "Rhythm Game God"
	elif all_stats[1]["osu_notes_hit_count"] > 500:
		p1title = "Carpal Tunnel Speedrunner"
	
	# Damage titles
	if all_stats[1]["total_damage_dealt"] > 10000:
		p1title = "Actually Bronze in League"
	elif all_stats[1]["total_damage_dealt"] > 5000:
		p1title = "Damage Chart MVP"
	
	# Structure titles
	if all_stats[1].get("towers_destroyed", 0) >= 3:
		p1title = "Tower Demolisher"
	elif all_stats[1].get("nexus_destroyed", 0) > 0:
		p1title = "Nexus Hunter"
	
	# Special titles
	if all_stats[1]["player_kill_count"] > 3 && all_stats[1]["death_count"] > 3:
		p1title = "Worth the Int"
	elif all_stats[1]["ability_used_count"] > 15:
		p1title = "Button Masher Pro"
	elif all_stats[1]["mana_generated"] > 1000:
		p1title = "Mana Machine"
	elif all_stats[1]["player_kill_count"] > 3 && all_stats[1]["osu_highest_combo"] > 50:
		p1title = "Moves Like Faker"
	elif all_stats[1]["player_kill_count"] > 0 && all_stats[1]["death_count"] == 0:
		p1title = "KDA Player"
	elif all_stats[1]["minion_spawn_count"] > 30:
		p1title = "Minion Commander"
	elif all_stats[1]["match_length"] < 300000: # Less than 5 minutes
		p1title = "Speedrunner"
	elif all_stats[1]["osu_highest_combo"] > 0 && all_stats[1]["player_kill_count"] > 0:
		p1title = "Click Circles, Destroy Nexus"
	
	$MainContainer/ContentContainer/StatsGrid/Player1Info/PlayerDetails/PlayerTitle.text = p1title if p1title else ""


	if len(sorted_keys) > 1:
		$MainContainer/ContentContainer/StatsGrid/Player2KDA.text = str(all_stats[second_id]["player_kill_count"]) + " / " + str(all_stats[second_id]["death_count"])
		$MainContainer/ContentContainer/StatsGrid/Player2Mana.text = str(all_stats[second_id]["mana_generated"])
		$MainContainer/ContentContainer/StatsGrid/Player2Minions.text = str(all_stats[second_id]["minion_kill_count"])
		$MainContainer/ContentContainer/StatsGrid/Player2Combo.text = str(all_stats[second_id]["osu_highest_combo"])
		$MainContainer/ContentContainer/StatsGrid/Player2Spawned.text = str(all_stats[second_id]["minion_spawn_count"])
		
		var p2title = ""
		# Death-related titles
		if all_stats[second_id]["death_count"] > 10:
			p2title = "Professional Inter"
		elif all_stats[second_id]["death_count"] == 0:
			p2title = "Can't touch this"
		
		# Kill/minion-related titles
		if all_stats[second_id]["minion_kill_count"] > 100:
			p2title = "The Minion Slayer"
		elif all_stats[second_id]["player_kill_count"] > 5:
			p2title = "Challenger in Training"
		
		# Rhythm game titles
		if all_stats[second_id]["osu_highest_combo"] > 100:
			p2title = "Missed Life, Not Notes"
		elif all_stats[second_id]["osu_acc_sum"] > 0 && all_stats[second_id]["osu_acc_notes_count"] > 0 && (float(all_stats[second_id]["osu_acc_sum"]) / all_stats[second_id]["osu_acc_notes_count"]) > 0.9:
			p2title = "Rhythm Game God"
		elif all_stats[second_id]["osu_notes_hit_count"] > 500:
			p2title = "Carpal Tunnel Speedrunner"
		
		# Damage titles
		if all_stats[second_id]["total_damage_dealt"] > 10000:
			p2title = "Actually Bronze in League"
		elif all_stats[second_id]["total_damage_dealt"] > 5000:
			p2title = "Damage Chart MVP"
		
		# Structure titles
		if all_stats[second_id].get("towers_destroyed", 0) >= 3:
			p2title = "Tower Demolisher"
		elif all_stats[second_id].get("nexus_destroyed", 0) > 0:
			p2title = "Nexus Hunter"
		
		# Special titles
		if all_stats[second_id]["player_kill_count"] > 3 && all_stats[second_id]["death_count"] > 3:
			p2title = "Worth the Int"
		elif all_stats[second_id]["ability_used_count"] > 15:
			p2title = "Button Masher Pro"
		elif all_stats[second_id]["mana_generated"] > 1000:
			p2title = "Mana Machine"
		elif all_stats[second_id]["player_kill_count"] > 3 && all_stats[second_id]["osu_highest_combo"] > 50:
			p2title = "Moves Like Faker"
		elif all_stats[second_id]["player_kill_count"] > 0 && all_stats[second_id]["death_count"] == 0:
			p2title = "KDA Player"
		elif all_stats[second_id]["minion_spawn_count"] > 30:
			p2title = "Minion Commander"
		elif all_stats[second_id]["match_length"] < 300000: # Less than 5 minutes
			p2title = "Speedrunner"
		elif all_stats[second_id]["osu_highest_combo"] > 0 && all_stats[second_id]["player_kill_count"] > 0:
			p2title = "Click Circles, Destroy Nexus"
		
		$MainContainer/ContentContainer/StatsGrid/Player2Info/PlayerDetails/PlayerTitle.text = p2title if p2title else ""
	var match_length = 0
	for key in all_stats:
		match_length = max(match_length, all_stats[key]['match_length'])
	var total_seconds = match_length / 1000 # Convert ms to seconds
	var hours = total_seconds / 3600
	var minutes = (total_seconds % 3600) / 60
	var seconds = total_seconds % 60
	$MainContainer/MatchDetailsSection/MatchStats/MatchTimeValue.text = "%02d:%02d:%02d" % [hours, minutes, seconds]

func update_structures_display():
	var my_id = multiplayer.get_unique_id()
	var all_stats = MatchStats.get_all_stats()
	
	var blue_player_id = 1
	var red_player_id = 0
	print("all stats", all_stats)
	for player_id in all_stats.keys():
		if player_id != blue_player_id:
			red_player_id = player_id
			break
	if MatchStats.singleplayer:
		blue_player_id = red_player_id
		red_player_id = -1
	print("blue player id", blue_player_id, "red player id", red_player_id)
	var left_structures = $MainContainer/HeaderSection/ResultDisplay/LeftStructures
	var right_structures = $MainContainer/HeaderSection/ResultDisplay/RightStructures
	
	var left_nexus = left_structures.get_node("Nexus")
	var left_towers = [
		left_structures.get_node("TowerContainer/Tower3"),
		left_structures.get_node("TowerContainer/Tower2"),
		left_structures.get_node("TowerContainer/Tower1")
	]
	
	var right_nexus = right_structures.get_node("Nexus")
	var right_towers = [
		right_structures.get_node("TowerContainer/Tower1"),
		right_structures.get_node("TowerContainer/Tower2"),
		right_structures.get_node("TowerContainer/Tower3")
	]
	
	left_nexus.hide()
	right_nexus.hide()
	for i in range(3):
		left_towers[i].hide()
		right_towers[i].hide()
	
	var blue_tower_kills = all_stats[blue_player_id].get("towers_destroyed", 0) if blue_player_id in all_stats else 0
	var red_tower_kills = all_stats[red_player_id].get("towers_destroyed", 0) if red_player_id in all_stats else 0
	
	var blue_kills_nexus = all_stats[blue_player_id].get("nexus_destroyed", 0) if blue_player_id in all_stats else 0
	var red_kills_nexus = all_stats[red_player_id].get("nexus_destroyed", 0) if red_player_id in all_stats else 0
	
	
	for i in range(blue_tower_kills):
		left_towers[i].show()
	if blue_kills_nexus > 0:
		left_nexus.show()
	
	for i in range(red_tower_kills):
		right_towers[i].show()
	if red_kills_nexus > 0:
		right_nexus.show()
	

func _ready():
	if len(GameManager.Players) <= 1:
		%Player2Info.hide()
		%Player2KDA.hide()
		%Player2Mana.hide()
		%Player2Minions.hide()
		%Player2Combo.hide()
		%Player2Spawned.hide()
	call_deferred("update_stats_display")
	call_deferred("update_structures_display")
	
	if !has_node("CountdownTimer"):
		timer = Timer.new()
		timer.name = "CountdownTimer"
		add_child(timer)
	
	timer.wait_time = 5.0
	timer.one_shot = true
	
	timer.timeout.connect(_on_timer_timeout)
	
	progress_bar.value = 100
	timer_value_label.text = str(int(display_time))
	timer.start()


func _process(delta: float) -> void:
	timer_value_label.text = str(int(ceil(timer.time_left)))
	progress_bar.value = timer.time_left / timer.wait_time * 100

func _on_timer_timeout():
	enable_buttons()
	$MainContainer/TimerSection/TimerContainer/TimerValue.hide()

func enable_buttons():
	if buttons_enabled:
		return
		
	buttons_enabled = true
	$MainContainer/ButtonsContainer/MainMenuButton.disabled = false
	$MainContainer/ButtonsContainer/ExitGameButton.disabled = false
	
	$MainContainer/ButtonsContainer/MainMenuButton.pressed.connect(_on_main_menu_pressed)
	$MainContainer/ButtonsContainer/ExitGameButton.pressed.connect(_on_exit_game_pressed)

func _on_main_menu_pressed():
	get_tree().change_scene_to_file("res://title/titlescreen.tscn")

func _on_exit_game_pressed():
	get_tree().quit()

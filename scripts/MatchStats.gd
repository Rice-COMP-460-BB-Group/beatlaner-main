extends Node

# Store stats using player's unique multiplayer ID as the key
# The value will be another dictionary holding the stats for that player
var player_stats: Dictionary = {}

func _ready() -> void:
	name = 'MatchStats'

# Call this function from each player instance BEFORE changing the scene
@rpc("any_peer")
func update_stat(player_id: int, stat_name: String, stat_value):
	if player_id not in player_stats:
		player_stats[player_id] = {
			"player_kill_count": 0,
			"minion_kill_count": 0,
			"total_damage_dealt": 0,
			"total_damage_received": 0,
			"death_count": 0,
			"ability_used_count": 0,
			"osu_highest_combo": 0,
			"osu_notes_hit_count": 0,
			"osu_average_accuracy": 0.0, 
			"minion_spawn_count": 0,
			"match_length": 0,
			"mana_generated": 0
		}

	player_stats[player_id][stat_name] = stat_value


func register_player_stats(player_id: int, stats: Dictionary) -> void:
	print("Registering stats for player: ", player_id)
	player_stats[player_id] = stats
	# Optional: Print registered stats for debugging
	# print("Stats: ", stats)

# Call this function from the game_win/game_over scene to get the data
func get_all_stats() -> Dictionary:
	return player_stats

# Optional: Call this when starting a new match or returning to main menu
func reset_stats() -> void:
	player_stats.clear()
	print("Match stats reset.")

extends Node

# Store stats using player's unique multiplayer ID as the key
var player_stats: Dictionary = {1: {
			"player_kill_count": 0,
			"minion_kill_count": 0,
			"total_damage_dealt": 0,
			"total_damage_received": 0,
			"death_count": 0,
			"ability_used_count": 0,
			"osu_highest_combo": 0,
			"osu_notes_hit_count": 0,
			"osu_average_accuracy": 0.0,
			"osu_acc_notes_count": 0,
			"osu_acc_sum": 0,
			"minion_spawn_count": 0,
			"match_length": 0,
			"mana_generated": 0
		}}

func _ready() -> void:
	name = 'MatchStats'
	# We need to ensure this node has network authority that all clients respect
	set_multiplayer_authority(1)  # Server is always ID 1

# This is the main function clients should call to update their stats
@rpc("any_peer", "reliable")
func update_stat(player_id: int, stat_name: String, stat_value):
	print("Update stat called for player: ", player_id, " stat: ", stat_name, " value: ", stat_value)
	
	# Initialize the player's stats if needed
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
			"osu_acc_notes_count": 0,
			"osu_acc_sum": 0,
			"minion_spawn_count": 0,
			"match_length": 0,
			"mana_generated": 0
		}
	
	# Update the stat on the server
	player_stats[player_id][stat_name] = stat_value
	
	# If this is the server, we need to sync this update to all clients
	if multiplayer.is_server():
		print("Server broadcasting stat update to all clients")
		rpc("sync_stat_to_clients", player_id, stat_name, stat_value)

# This RPC is called by the server to update stats on all clients
@rpc("authority", "reliable")
func sync_stat_to_clients(player_id: int, stat_name: String, stat_value):
	print("Client received stat update for player: ", player_id, " stat: ", stat_name)
	
	# Initialize the player's stats if needed
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
			"osu_acc_notes_count": 0,
			"osu_acc_sum": 0,
			"minion_spawn_count": 0,
			"match_length": 0,
			"mana_generated": 0
		}
	
	# Update the stat on the client
	player_stats[player_id][stat_name] = stat_value

# Register a new player in the stats system
@rpc("any_peer", "reliable")
func register_player_stats(player_id: int) -> void:
	print("Registering stats for player: ", player_id)
	
	# Initialize the player's stats
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
			"osu_acc_notes_count": 0,
			"osu_acc_sum": 0,
			"minion_spawn_count": 0,
			"match_length": 0,
			"mana_generated": 0
		}
	
	# If this is the server, sync all player stats to the new client
	if multiplayer.is_server():
		# Only sync back to the player who just registered
		var sender_id = multiplayer.get_remote_sender_id()
		print("Server sending full stats to newly registered player:", sender_id)
		rpc_id(sender_id, "sync_all_stats", player_stats)

# Sync the complete stats dictionary from server to clients
@rpc("authority", "reliable")
func sync_all_stats(stats: Dictionary) -> void:
	print("Received full stats sync from server")
	player_stats = stats.duplicate(true)  # Deep copy to avoid reference issues

# Get all stats - used by the game over scene
func get_all_stats() -> Dictionary:
	return player_stats

# Reset stats
func reset_stats() -> void:
	print('reset stats')
	player_stats.clear()
	
	# If server, tell clients to clear stats too
	if multiplayer.is_server():
		rpc("clear_stats")

# Clients clear their stats when told by server
@rpc("authority", "reliable")
func clear_stats() -> void:
	print('Clearing stats on client')
	player_stats.clear()

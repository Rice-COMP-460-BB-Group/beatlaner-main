extends Control

func _ready():
	$VBoxContainer/Start.grab_focus()

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://main/Main.tscn")


func _on_exit_pressed() -> void:
	get_tree().quit()

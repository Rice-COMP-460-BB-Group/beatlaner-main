extends Control

func _ready():
	$VBoxContainer/Start.grab_focus()

func _on_start_pressed() -> void:
	$Confirm.play()
	await $Confirm.finished
	get_tree().change_scene_to_file.bind("res://main/Main.tscn").call_deferred()


func _on_exit_pressed() -> void:
	$Confirm.play()
	await $Confirm.finished
	get_tree().quit()


func _on_button_focus_entered() -> void:
	$Focus.play()

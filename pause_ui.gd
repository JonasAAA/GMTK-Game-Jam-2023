extends CanvasLayer

func _on_Resume_pressed() -> void:
	hide()
	get_tree().paused = false

func _on_Exit_pressed() -> void:
	get_tree().paused = false
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://main_menu.tscn")

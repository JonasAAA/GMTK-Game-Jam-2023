extends CanvasLayer

func _on_Back_pressed():
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://main_menu.tscn")

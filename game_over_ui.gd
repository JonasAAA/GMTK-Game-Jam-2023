extends CanvasLayer

onready var label = $Label

func start(text: String) -> void:
	label.text = text
	show()

func _on_Restart_pressed() -> void:
	# warning-ignore:return_value_discarded
	get_tree().reload_current_scene()

func _on_MainMenu_pressed():
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://main_menu.tscn")

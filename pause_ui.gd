extends CanvasLayer

var cur_progress: int

func start_show(current_progress: int) -> void:
	show()
	self.cur_progress = current_progress

func _on_Resume_pressed() -> void:
	GlobalState.wwise_set_switch_id(AK.SWITCHES.PROGRESS.GROUP, cur_progress, GlobalState)
	hide()
	get_tree().paused = false

func _on_Exit_pressed() -> void:
	GlobalState.wwise_set_switch_id(AK.SWITCHES.PROGRESS.GROUP, AK.SWITCHES.PROGRESS.SWITCH.ZERO, GlobalState)
	get_tree().paused = false
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://main_menu.tscn")

extends CanvasLayer

onready var high_score: Label

func _on_MainMenu_tree_entered() -> void:
	if high_score == null:
		high_score = $HighScore
	high_score.text = "High score {high_score}".format({"high_score": GlobalState.high_score})

func _on_Start_pressed() -> void:
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://level.tscn")

func _on_Rules_pressed() -> void:
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://rules.tscn")
	
func _on_Credits_pressed() -> void:
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://credits.tscn")

func _on_Exit_pressed() -> void:
	GlobalState.save_high_score()
	get_tree().quit()

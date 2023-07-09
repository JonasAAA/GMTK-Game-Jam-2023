extends CanvasLayer

signal pause_pressed

onready var label = $Label

func update(health: int, score: int) -> void:
	label.text = "Health {health}\nScore {score}".format({"health": health, "score": score})

func _on_Pause_pressed() -> void:
	emit_signal("pause_pressed")
#	get_tree().paused = true

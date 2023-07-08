extends CanvasLayer

onready var label = $Label

func set_health(health: float) -> void:
	label.text = "Health {health}".format({"health": health})

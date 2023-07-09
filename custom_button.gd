extends Button

export var is_forward = true

func _ready() -> void:
	Wwise.register_game_obj(self, "CustomButton")

func _on_CustomButton_mouse_entered():
	Wwise.post_event_id(AK.EVENTS.UIHOVER, self)

func _on_CustomButton_pressed() -> void:
	print("button pressed")
	var event: int
	if is_forward:
		event = AK.EVENTS.UICLICK
	else:
		event = AK.EVENTS.UICLICKBACK
	Wwise.post_event_id(event, self)

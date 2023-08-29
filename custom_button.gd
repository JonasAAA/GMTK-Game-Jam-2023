extends Button

export var is_forward = true

func _ready() -> void:
	GlobalState.wwise_register_game_obj(self, "CustomButton")

func _on_CustomButton_mouse_entered():
	GlobalState.wwise_post_event_id(AK.EVENTS.UIHOVER, self)

func _on_CustomButton_pressed() -> void:
	var event: int
	if is_forward:
		event = AK.EVENTS.UICLICK
	else:
		event = AK.EVENTS.UICLICKBACK
		GlobalState.wwise_post_event_id(event, self)

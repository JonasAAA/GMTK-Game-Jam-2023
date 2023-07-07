extends Node2D

func _ready() -> void:
	var result = Wwise.load_bank_id(AK.BANKS.INIT)
	print("is INIT loading successful? ", result)
	result = Wwise.load_bank_id(AK.BANKS.DEMO_SOUNDBANK)
	print("is DEMO_SOUNDBANK loading successful? ", result)
	result = Wwise.register_listener(self)
	print("is registering listener successful? ", result)
	result = Wwise.register_game_obj(self, "Level")
	print("is wwise game object registering successful? ", result)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_select"):
		var playing_id = Wwise.post_event_id(AK.EVENTS.DEMO_EVENT, self)
		print("Triggering Wwise event DEMO_EVENT")

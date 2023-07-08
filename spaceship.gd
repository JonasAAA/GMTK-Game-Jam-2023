extends RigidBody2D

export var health = 100
export var target_speed = 100

func _ready() -> void:
	Wwise.register_game_obj(self, "Spaceship")

func _on_Spaceship_body_entered(body: Node) -> void:
#	print("mass ", body.mass, " velocity diff ", body.linear_velocity.distance_to(linear_velocity))
	health -= body.mass * body.linear_velocity.distance_to(linear_velocity) / 1000
	health = max(0, health)
	print(body.mass, " ", body.linear_velocity.distance_to(linear_velocity))
	Wwise.set_rtpc_id(AK.GAME_PARAMETERS.MASS, body.mass)
	Wwise.set_rtpc_id(AK.GAME_PARAMETERS.SPEED, body.linear_velocity.distance_to(linear_velocity))
	Wwise.post_event_id(AK.EVENTS.SHIPCOLLISION, self)

func _integrate_forces(state: Physics2DDirectBodyState) -> void:
	pass

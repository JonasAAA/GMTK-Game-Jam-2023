extends RigidBody2D

export var health = 100
export var target_speed = 100

func _on_Spaceship_body_entered(body: Node) -> void:
#	print("mass ", body.mass, " velocity diff ", body.linear_velocity.distance_to(linear_velocity))
	health -= body.mass * body.linear_velocity.distance_to(linear_velocity) / 1000
	health = max(0, health)

func _integrate_forces(state: Physics2DDirectBodyState) -> void:
	pass

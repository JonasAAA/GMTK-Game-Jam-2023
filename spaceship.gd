extends RigidBody2D

onready var thrust = $Thrust
export var health = 100
export var target_speed = 200
const drag = 10
const thrust_vel = 100
var close_asteroid_count: int

func _ready() -> void:
	close_asteroid_count = 0
	Wwise.register_game_obj(self, "Spaceship")

func _on_Spaceship_body_entered(body: Node) -> void:
#	print("mass ", body.mass, " velocity diff ", body.linear_velocity.distance_to(linear_velocity))
	health -= body.mass * body.linear_velocity.distance_to(linear_velocity) / 1000
	health = max(0, health)
	
	var wwise_mass = sqrt(body.mass)
	var wwise_speed = body.linear_velocity.distance_to(linear_velocity) / 10
	print(wwise_mass, " ", wwise_speed)
	Wwise.set_rtpc_id(AK.GAME_PARAMETERS.MASS, wwise_mass)
	Wwise.set_rtpc_id(AK.GAME_PARAMETERS.SPEED, wwise_speed)
	Wwise.post_event_id(AK.EVENTS.SHIPCOLLISION, self)

func _integrate_forces(state: Physics2DDirectBodyState) -> void:
	print("close_asteroid_count ", close_asteroid_count)
	if close_asteroid_count <= 5:
		Wwise.set_switch_id(AK.SWITCHES.INTENSITY.GROUP, AK.SWITCHES.INTENSITY.SWITCH.SMALL, self)
	elif close_asteroid_count <= 10:
		Wwise.set_switch_id(AK.SWITCHES.INTENSITY.GROUP, AK.SWITCHES.INTENSITY.SWITCH.MEDIUM, self)
	else:
		Wwise.set_switch_id(AK.SWITCHES.INTENSITY.GROUP, AK.SWITCHES.INTENSITY.SWITCH.BIG, self)
	if health < 0:
		return
#	if state.linear_velocity.x
	var ideal_vel = Vector2.UP * target_speed
	var up_speed = Vector2.UP.dot(state.linear_velocity)
	var right_speed = Vector2.RIGHT.dot(state.linear_velocity)
	var new_up_speed: float
	if up_speed >= target_speed:
		new_up_speed = max(target_speed, up_speed - drag * state.step)
		thrust.emitting = false
	else:
		new_up_speed = min(target_speed, up_speed + thrust_vel * state.step)
		thrust.emitting = true
		
	var new_right_speed = sign(right_speed) * max(0, abs(right_speed) - drag * state.step)
	state.linear_velocity = Vector2.UP * new_up_speed + Vector2.RIGHT * new_right_speed


func _on_Area2D_body_entered(body: Node) -> void:
	if body is Asteroid:
		close_asteroid_count += 1

func _on_Area2D_body_exited(body: Node) -> void:
	if body is Asteroid:
		close_asteroid_count -= 1

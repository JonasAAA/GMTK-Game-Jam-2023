extends RigidBody2D

onready var thrust = $Thrust
export var health = 100
export var target_speed = 200
const drag = 10
const thrust_vel = 100
var max_small_intensity_asteroids: int
var min_medium_intensity_asteroids: int
var max_medium_intensity_asteroids: int
var min_high_intensity_asteroids: int
var close_asteroid_count: int
var cur_intensity: int

func _ready() -> void:
	close_asteroid_count = 0
	set_intensity(AK.SWITCHES.INTENSITY.SWITCH.SMALL)
	GlobalState.wwise_register_game_obj(self, "Spaceship")

func init(start_spawn_coeff: float, spawn_coeff_increase_speed: float) -> void:
	var asteroid_boundary_one: int = round(3.5 * start_spawn_coeff) as int
	var asteroid_boundary_two: int = round(3.5 * (start_spawn_coeff + spawn_coeff_increase_speed)) as int
	max_small_intensity_asteroids = asteroid_boundary_one + 1
	min_medium_intensity_asteroids = asteroid_boundary_one - 1
	max_medium_intensity_asteroids = asteroid_boundary_two + 1
	min_high_intensity_asteroids = asteroid_boundary_two - 1

func _on_Spaceship_body_entered(body: Node) -> void:
#	print("mass ", body.mass, " velocity diff ", body.linear_velocity.distance_to(linear_velocity))
	health -= body.mass * body.linear_velocity.distance_to(linear_velocity) / 3000
	health = max(0, health)
	
	var wwise_mass = sqrt(body.mass)
	var wwise_speed = body.linear_velocity.distance_to(linear_velocity) / 10
	print(wwise_mass, " ", wwise_speed)
	GlobalState.wwise_set_rtpc_id(AK.GAME_PARAMETERS.MASS, wwise_mass, self)
	GlobalState.wwise_set_rtpc_id(AK.GAME_PARAMETERS.SPEED, wwise_speed, self)
	GlobalState.wwise_post_event_id(AK.EVENTS.SHIPCOLLISION, self)

func set_intensity(new_intensity: int) -> void:
	cur_intensity = new_intensity
	GlobalState.wwise_set_switch_id(AK.SWITCHES.INTENSITY.GROUP, new_intensity, GlobalState)

func _integrate_forces(state: Physics2DDirectBodyState) -> void:
	if cur_intensity == AK.SWITCHES.INTENSITY.SWITCH.SMALL:
		if close_asteroid_count > max_small_intensity_asteroids:
			set_intensity(AK.SWITCHES.INTENSITY.SWITCH.MEDIUM)
	elif cur_intensity == AK.SWITCHES.INTENSITY.SWITCH.MEDIUM:
		if close_asteroid_count < min_medium_intensity_asteroids:
			set_intensity(AK.SWITCHES.INTENSITY.SWITCH.SMALL)
		elif close_asteroid_count > max_medium_intensity_asteroids:
			set_intensity(AK.SWITCHES.INTENSITY.SWITCH.BIG)
	elif cur_intensity == AK.SWITCHES.INTENSITY.SWITCH.BIG:
		if close_asteroid_count < min_high_intensity_asteroids:
			set_intensity(AK.SWITCHES.INTENSITY.SWITCH.MEDIUM)
	else:
		assert(false)

	if health < 0:
		return
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
		print("close_asteroid_count ", close_asteroid_count)

func _on_Area2D_body_exited(body: Node) -> void:
	if body is Asteroid:
		close_asteroid_count -= 1
		print("close_asteroid_count ", close_asteroid_count)

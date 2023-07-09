extends RigidBody2D

class_name Asteroid

class DragInfo:
	var start_time_msec: int
	var local_start_pos: Vector2
	
	func _init(time_msec: int, local_pos: Vector2) -> void:
		start_time_msec = time_msec
		local_start_pos = local_pos

const max_impulse: float = 50000.0
const max_momentum: float = 500000.0
onready var sprite = $Sprite
onready var collision_shape = $CollisionShape
var shape_start_radius: float
var drag_info: DragInfo = null

func _ready() -> void:
	shape_start_radius = collision_shape.shape.radius
	set_process_input(true)

func initialize(start_pos: Vector2, start_vel: Vector2, start_angular_vel: float, width: float, start_mass: float) -> void:
	position = start_pos
	linear_velocity = start_vel
	angular_velocity = start_angular_vel
	mass = start_mass
	var scale = width / sprite.texture.get_width()
	sprite.scale = Vector2(scale, scale)
	# needed so that the radius change doesn't affect all asteroids
	collision_shape.shape = CircleShape2D.new()
	collision_shape.shape.radius = shape_start_radius * scale

func get_mouse_local_pos() -> Vector2:
#	print("mouse local pos ", get_viewport().get_mouse_position())
	return get_viewport().get_mouse_position() - position

func get_cur_time_msec() -> int:
	return OS.get_ticks_msec()

func _on_Asteroid_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if drag_info != null:
		return
	if event is InputEventMouseButton:
		if event.pressed && event.button_index == BUTTON_LEFT:
			drag_info = DragInfo.new(get_cur_time_msec(), get_mouse_local_pos())

func _integrate_forces(state: Physics2DDirectBodyState) -> void:
	if not Input.is_mouse_button_pressed(BUTTON_LEFT):
		drag_info = null
	if drag_info != null:
#		var desired_move_dir = (get_mouse_local_pos() - drag_info.local_start_pos).normalized()
#		var orth_move_dir = desired_move_dir.rotated(PI / 2)
#		var parallel_speed = state.linear_velocity.dot(desired_move_dir)
#		var orth_speed = state.linear_velocity.dot(orth_move_dir)
#		var orth_speed_sign = sign(orth_speed)
#		var max_speed_change = max_impulse / mass
#		var orth_speed_change = -orth_speed_sign * min(orth_speed_sign * orth_speed, max_speed_change / sqrt(2))
#		var parallel_speed_change = sqrt(max_speed_change * max_speed_change - orth_speed_change * orth_speed_change)
#		state.linear_velocity += parallel_speed_change * desired_move_dir #+ orth_speed_change * orth_move_dir
		
#		var max_speed = max_momentum / mass
#		var time_in_orth = orth_speed / max_speed_change
#		var time_in_parallel = max_speed - orth_speed
#		var max_force = max_impulse / 
#		var ideal_impulse = (get_mouse_local_pos() - drag_info.local_start_pos) / state.step - state.linear_velocity
		
#		var impulse: Vector2 = 0.001 * (get_mouse_local_pos() - drag_info.local_start_pos) / state.step
#		state.linear_velocity += impulse
		
		
		
		
		
		
		
#		var drag = 100000 / mass
#		var speed = state.linear_velocity.length()
#		var final_speed: float
#		if speed >= drag * state.step:
#			final_speed = speed - drag * state.step
#		else:
#			final_speed = 0
##		state.linear_velocity *= 0.95
#		state.linear_velocity = state.linear_velocity.normalized() * final_speed
		
		var ideal_vel_change = (get_mouse_local_pos() - drag_info.local_start_pos) / state.step - state.linear_velocity
		var ideal_vel_change_length = ideal_vel_change.length()
		var vel_change: Vector2
		var max_speed_change = max_impulse / mass
		if ideal_vel_change_length >= max_speed_change:
			vel_change = ideal_vel_change / ideal_vel_change_length * max_speed_change
		else:
			vel_change = ideal_vel_change
		state.linear_velocity += vel_change
		
		state.linear_velocity = min(state.linear_velocity.length(), max_momentum / mass) * state.linear_velocity.normalized()










		
#		drag_info = DragInfo.new(get_cur_time_msec(), get_mouse_local_pos())
#	if drag_info != null && !Input.is_mouse_button_pressed(BUTTON_LEFT):
#		var impulse: Vector2 = (get_mouse_local_pos() - drag_info.local_start_pos) / (get_cur_time_msec() - drag_info.start_time_msec) * 100
#		state.linear_velocity += impulse
#		drag_info = null


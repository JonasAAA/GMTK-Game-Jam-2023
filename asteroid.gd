extends RigidBody2D

class_name Asteroid

class DragInfo:
	var start_time_msec: int
	var local_start_pos: Vector2
	
	func _init(time_msec: int, local_pos: Vector2) -> void:
		start_time_msec = time_msec
		local_start_pos = local_pos

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
	return get_viewport().get_mouse_position()

func get_cur_time_msec() -> int:
	return OS.get_ticks_msec()

func _on_Asteroid_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if drag_info != null:
		return
	if event is InputEventMouseButton:
		if event.pressed && event.button_index == BUTTON_LEFT:
			drag_info = DragInfo.new(get_cur_time_msec(), get_mouse_local_pos())

func _integrate_forces(state: Physics2DDirectBodyState) -> void:
	if drag_info != null && !Input.is_mouse_button_pressed(BUTTON_LEFT):
		var impulse: Vector2 = (get_mouse_local_pos() - drag_info.local_start_pos) / (get_cur_time_msec() - drag_info.start_time_msec) * 100;
		state.linear_velocity += impulse
		drag_info = null


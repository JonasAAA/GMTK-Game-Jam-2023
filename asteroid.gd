extends RigidBody2D

class_name Asteroid

onready var sprite = $Sprite
onready var collision_shape = $CollisionShape
var shape_start_radius: float

func _ready() -> void:
	shape_start_radius = collision_shape.shape.radius

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

func _on_Asteroid_input_event(viewport, event, shape_idx):
	print("input event")

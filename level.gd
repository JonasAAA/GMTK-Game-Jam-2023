extends Node2D

onready var camera = $Camera
onready var spaceship = $Spaceship
onready var level_ui = $LevelUI
var asteroid_template = preload("res://asteroid.tscn")
var random: RandomNumberGenerator
var asteroids: Array
const asteroid_despawn_dist = 3000

func _ready() -> void:
	Wwise.load_bank_id(AK.BANKS.INIT)
	Wwise.load_bank_id(AK.BANKS.SOUNDS)
	Wwise.register_listener(self)
	
	random = RandomNumberGenerator.new()
	random.seed = OS.get_ticks_msec()
#	get_tree().set_debug_collisions_hint(true) 
	spaceship.position = Vector2.ZERO

func _physics_process(delta: float) -> void:
	if random.randf() < 0.1:
		spawn_asteroid()
	remove_far_asteroids()
	camera.position = spaceship.position
	level_ui.set_health(spaceship.health)
	if spaceship.health == 0:
		get_tree().reload_current_scene()
#	print("velocity ", spaceship.linear_velocity)
#	print(spaceship.health)
#	print(spaceship.linear_velocity)

func spawn_asteroid() -> void:
	var width = pow(2, random.randf_range(3, 7))
	var mass = width * width / 10
#	print("mass ", mass)
	var position: Vector2 = spaceship.position + Vector2(random.randf_range(-1000, 1000), random.randf_range(-1000, 1000))
	var velocity: Vector2 = Vector2(random.randf_range(-10000, 10000), random.randf_range(-10000, 10000)) / mass
	var angular_vel: float = random.randf_range(-1000, 1000) / mass
	var asteroid: Asteroid = asteroid_template.instance()
	add_child(asteroid)
	asteroid.initialize(position, velocity, angular_vel, width, mass)
	asteroids.append(asteroid)

func remove_far_asteroids() -> void:
	var next_asteroid_array: Array = []
	for asteroid in asteroids:
		if asteroid.position.distance_to(spaceship.position) > asteroid_despawn_dist:
			asteroid.queue_free()
		else:
			next_asteroid_array.append(asteroid)
	asteroids = next_asteroid_array

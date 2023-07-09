extends Node2D

onready var camera = $Camera
onready var spaceship = $Spaceship
onready var level_ui = $LevelUI
onready var pause_ui = $PauseUI
onready var game_over_ui = $GameOverUI
var asteroid_template = preload("res://asteroid.tscn")
var random: RandomNumberGenerator
var asteroids: Array
const asteroid_despawn_dist = 3000
var start_time_msec: int
var score: int = 0
var playing: bool = false

func _ready() -> void:
	Wwise.register_game_obj(self, "Level")
	Wwise.set_switch_id(AK.SWITCHES.PROGRESS.GROUP, AK.SWITCHES.PROGRESS.SWITCH.LOW, self)
	random = RandomNumberGenerator.new()
	random.seed = OS.get_ticks_msec()
	print("random seed ", random.seed)
#	get_tree().set_debug_collisions_hint(true) 
	spaceship.position = Vector2.ZERO
	spaceship.linear_velocity = Vector2.ZERO
	game_over_ui.hide()
	pause_ui.hide()
	start_time_msec = OS.get_ticks_msec()
	playing = true
	level_ui.show()

func _physics_process(_delta: float) -> void:
	if score > 200:
		Wwise.set_switch_id(AK.SWITCHES.PROGRESS.GROUP, AK.SWITCHES.PROGRESS.SWITCH.MID, self)
	if not playing:
		return
#	var num_asteroids_to_spawn: int = random.randi_range(0, 1)
#	for i in num_asteroids_to_spawn:
#		spawn_asteroid()
	if random.randf() < 0.1 * abs(spaceship.linear_velocity.y) / spaceship.target_speed:
		spawn_asteroid()
	remove_far_asteroids()
	camera.position = spaceship.position
	# warning-ignore:integer_division
	score = (OS.get_ticks_msec() - start_time_msec) / 100
	level_ui.update(int(spaceship.health), score)
	if int(spaceship.health) == 0:
		game_over()
#	print("velocity ", spaceship.linear_velocity)
#	print(spaceship.health)
#	print(spaceship.linear_velocity)

func game_over() -> void:
	Wwise.set_switch_id(AK.SWITCHES.PROGRESS.GROUP, AK.SWITCHES.PROGRESS.SWITCH.ZERO, self)
	playing = false
	level_ui.hide()
	GlobalState.high_score = int(max(GlobalState.high_score, score))
	game_over_ui.start("Game over\nScore {score}\nHigh score {high_score}".format({"score": score, "high_score": GlobalState.high_score}))
#	get_tree().reload_current_scene()

func spawn_asteroid() -> void:
	var width = pow(2, random.randf_range(3, 7))
	var mass = width * width / 10
#	print("mass ", mass)
	var position: Vector2 = spaceship.position + random.randf_range(1000, 1100) * Vector2.UP.rotated(random.randf_range(-PI / 5, PI / 5))
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

func _on_LevelUI_pause_pressed() -> void:
	Wwise.set_switch_id(AK.SWITCHES.PROGRESS.GROUP, AK.SWITCHES.PROGRESS.SWITCH.ZERO, self)
	# this cureently doesn't work as all sounds are paused as well
#	Wwise.post_event_id(AK.EVENTS.UICLICKBACK, self)
	get_tree().paused = true
	pause_ui.show()

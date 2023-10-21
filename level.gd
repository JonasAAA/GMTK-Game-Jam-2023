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
var spawn_coeff: float

func _ready() -> void:
	random = RandomNumberGenerator.new()
	random.seed = OS.get_ticks_msec()
	print("random seed ", random.seed)
	# get_tree().set_debug_collisions_hint(true) 
	spaceship.position = Vector2.ZERO
	spaceship.bla
	spaceship.linear_velocity = Vector2.ZERO
	game_over_ui.hide()
	pause_ui.hide()
	start_time_msec = OS.get_ticks_msec()
	level_ui.show()
	spawn_coeff = 0.1

func _get_progress() -> int:
	if (not playing) or get_tree().paused:
		return AK.SWITCHES.PROGRESS.SWITCH.ZERO
	if score < GlobalState.mid_progress_score:
		return AK.SWITCHES.PROGRESS.SWITCH.LOW
	return AK.SWITCHES.PROGRESS.SWITCH.MID

func _wwise_update_progress() -> void:
	GlobalState.wwise_set_switch_id(AK.SWITCHES.PROGRESS.GROUP, _get_progress(), GlobalState)

func _physics_process(_delta: float) -> void:
	_wwise_update_progress()
	if not playing:
		return
	var old_spawn_coeff = spawn_coeff
	spawn_coeff += _delta * 0.01
	if floor(old_spawn_coeff / 0.1) < floor(spawn_coeff / 0.1):
		print("spawn coeff increased to ", spawn_coeff)
#	var num_asteroids_to_spawn: int = random.randi_range(0, 1)
#	for i in num_asteroids_to_spawn:
#		spawn_asteroid()
	if random.randf() < spawn_coeff * abs(spaceship.linear_velocity.y) / spaceship.target_speed:
		spawn_asteroid()
	remove_far_asteroids()
	camera.position = spaceship.position
	# warning-ignore:integer_division
	var prev_score = score
	score = (OS.get_ticks_msec() - start_time_msec) / 100
	if prev_score < GlobalState.mid_progress_score && GlobalState.mid_progress_score <= score:
		print("score reached ", GlobalState.mid_progress_score)
	level_ui.update(int(spaceship.health), score)
	if int(spaceship.health) == 0:
		game_over()
#	print("velocity ", spaceship.linear_velocity)
#	print(spaceship.health)
#	print(spaceship.linear_velocity)

func game_over() -> void:
	playing = false
	_wwise_update_progress()
	level_ui.hide()
	GlobalState.high_score = int(max(GlobalState.high_score, score))
	game_over_ui.start("Game over\nScore {score}\nHigh score {high_score}".format({"score": score, "high_score": GlobalState.high_score}))
#	get_tree().reload_current_scene()

func spawn_asteroid() -> void:
	var width = pow(2, random.randf_range(5, 7))
	var mass = width * width / 10
	#	print("mass ", mass)
	var position: Vector2 = spaceship.position + random.randf_range(1000, 1100) * Vector2.UP.rotated(random.randf_range(-PI, PI))
	var velocity: Vector2 = (Vector2.UP * random.randf_range(500, 1000)).rotated(random.randf_range(0, 2 * PI)) / sqrt(width)
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
	var cur_progress = _get_progress()
	get_tree().paused = true
	_wwise_update_progress()
	# this currently doesn't work as all sounds are paused as well
	# GlobalState.wwise_post_event_id(AK.EVENTS.UICLICKBACK, self)
	pause_ui.start_show(cur_progress)

func _on_Level_tree_entered() -> void:
	playing = true
	GlobalState.wwise_register_game_obj(self, "Level")
	_wwise_update_progress()

extends Node

const save_file_name = "user://save.json"

var high_score: int = -1 setget set_high_score, get_high_score

func set_high_score(new_value: int) -> void:
	high_score = new_value

func get_high_score() -> int:
	if high_score >= 0:
		return high_score
	var file = File.new()
	if not file.file_exists(save_file_name):
		high_score = 0
		return high_score
	file.open(save_file_name, File.READ)
	high_score = int(file.get_line())
	file.close()
	return high_score

func save_high_score() -> void:
	var file = File.new()
	file.open(save_file_name, File.WRITE)
	file.store_line(str(high_score))
	file.close()

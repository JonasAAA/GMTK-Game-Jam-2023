extends Node

const save_file_name = "user://save.json"
const mid_progress_score = 200

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

class _WwiseObjectData:
	var name: String
	var last_switch_states: Dictionary = {}

	func _init(object_name: String) -> void:
		self.name = object_name

const _wwise_object_to_data: Dictionary = {}
const _wwise_loaded_banks: PoolIntArray = PoolIntArray()
# Dictionary<int, WwiseSwitch>
const _wwise_switch_id_to_switch: Dictionary = {}

func _ready() -> void:
	_wwise_load_bank_id(AK.BANKS.INIT)
	_wwise_load_bank_id(AK.BANKS.SOUNDS)
	# Only one listener can be active at a time.
	# In this game, no more listeners must be registered.
	Wwise.register_listener(GlobalState)
	wwise_register_game_obj(GlobalState, "GlobalState")
	wwise_post_event_id(AK.EVENTS.MUSIC, GlobalState)
	wwise_set_switch_id(AK.SWITCHES.PROGRESS.GROUP, AK.SWITCHES.PROGRESS.SWITCH.ZERO, GlobalState)

func _wwise_get_object_data(game_object: Object) -> _WwiseObjectData:
	return _wwise_object_to_data[game_object]

func _wwise_load_bank_id(bank_id: int) -> void:
	assert(!(bank_id in _wwise_loaded_banks))
	_wwise_loaded_banks.append(bank_id)
	Wwise.load_bank_id(bank_id)

func wwise_register_game_obj(game_object: Object, game_object_name: String) -> void:
	assert(!(game_object in _wwise_object_to_data))
	Wwise.register_game_obj(game_object, game_object_name)
	_wwise_object_to_data[game_object] = _WwiseObjectData.new(game_object_name)

func wwise_post_event_id(event_id: int, game_object: Object) -> void:
	assert(game_object in _wwise_object_to_data)
	Wwise.post_event_id(event_id, game_object)

class _WwiseSwitchGroupAndState:
	var group: String
	var state: String

	func _init(switch_group: String, switch_state: String) -> void:
		self.group = switch_group
		self.state = switch_state

func _get_group_and_state_name(switch_group_id: int, switch_state_id: int) -> _WwiseSwitchGroupAndState:
	for group_name in AK.SWITCHES._dict:
		var switch: Dictionary = AK.SWITCHES._dict[group_name]
		if switch["GROUP"] == switch_group_id:
			var state_name_to_id: Dictionary = switch["SWITCH"]
			for state_name in state_name_to_id:
				if state_name_to_id[state_name] == switch_state_id:
					return _WwiseSwitchGroupAndState.new(group_name, state_name)
	assert(false)
	return null

func wwise_set_switch_id(switch_group_id: int, switch_state_id: int, game_object: Object) -> void:
	var object_data: _WwiseObjectData = _wwise_get_object_data(game_object)
	if !(switch_group_id in object_data.last_switch_states) or object_data.last_switch_states[switch_group_id] != switch_state_id:
		var group_and_state_name = _get_group_and_state_name(switch_group_id, switch_state_id)
		print(
			OS.get_time(),
			" ",
			"set_switch({switch_group}, {switch_state}, {game_object})".format({
				"switch_group": group_and_state_name.group,
				"switch_state": group_and_state_name.state,
				"game_object": object_data.name
			})
		)
		Wwise.set_switch_id(switch_group_id, switch_state_id, game_object)
	object_data.last_switch_states[switch_group_id] = switch_state_id

# rtpc_value must be between 0 and 100 (otherwise will be clipped) as per agreement with Paulius
func wwise_set_rtpc_id(rtpc_id: int, rtpc_value: float, game_object: Object) -> void:
	assert(game_object in _wwise_object_to_data)
	Wwise.set_rtpc_id(rtpc_id, rtpc_value, game_object)

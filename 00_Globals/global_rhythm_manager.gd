extends Node

signal beat_hit(beat_number: int, accuracy: float)
signal combo_changed(combo_count: int)
signal rhythm_mode_changed(is_active: bool)

# Rhythm tracking variables
var is_rhythm_active: bool = false
var bpm: float = 120.0
var beat_interval: float
var beat_timer: float = 0.0
var current_beat: int = 0

# Timing windows (in seconds)
var perfect_window: float = 0.1  # ±100ms for perfect timing
var good_window: float = 0.2     # ±200ms for good timing
var ok_window: float = 0.3       # ±300ms for ok timing

# Combo system
var current_combo: int = 0
var max_combo: int = 0
var combo_timer: float = 0.0
var combo_timeout: float = 2.0  # 2 seconds to maintain combo

# Rhythm mode settings
var rhythm_damage_bonus: float = 1.5  # 50% extra damage on perfect beat
var combo_damage_bonus: float = 0.1   # 10% extra damage per combo level

# Visual feedback
var beat_intensity: float = 0.0
var target_intensity: float = 1.0
var fade_speed: float = 5.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	calculate_beat_interval()

func calculate_beat_interval() -> void:
	beat_interval = 60.0 / bpm

func set_bpm(new_bpm: float) -> void:
	bpm = new_bpm
	calculate_beat_interval()

func start_rhythm_mode() -> void:
	is_rhythm_active = true
	beat_timer = 0.0
	current_beat = 0
	current_combo = 0
	rhythm_mode_changed.emit(true)
	print("Rhythm mode started at BPM: ", bpm)

func stop_rhythm_mode() -> void:
	is_rhythm_active = false
	rhythm_mode_changed.emit(false)
	current_combo = 0
	combo_changed.emit(0)

func _process(delta: float) -> void:
	if not is_rhythm_active:
		return

	# Update beat timer
	beat_timer += delta

	# Check for beat
	if beat_timer >= beat_interval:
		beat_timer -= beat_interval
		current_beat += 1
		_on_beat()

	# Update combo timer
	if combo_timer > 0:
		combo_timer -= delta
		if combo_timer <= 0:
			_combo_break()

	# Update visual intensity
	beat_intensity = move_toward(beat_intensity, target_intensity, fade_speed * delta)

func _on_beat() -> void:
	# Visual feedback pulse
	target_intensity = 1.0
	beat_intensity = 0.0

	# Emit beat signal for other systems
	beat_hit.emit(current_beat, 1.0)

	# Visual effects could be triggered here
	if EffectManager:
		EffectManager.create_rhythm_pulse()

func check_rhythm_timing() -> float:
	"""
	Returns timing accuracy:
	1.0 = perfect
	0.7 = good
	0.4 = ok
	0.0 = miss
	"""
	if not is_rhythm_active:
		return 0.0

	var time_since_beat: float = beat_timer
	var time_to_next_beat: float = beat_interval - beat_timer

	var closest_time: float = min(time_since_beat, time_to_next_beat)

	if closest_time <= perfect_window:
		return 1.0  # Perfect
	elif closest_time <= good_window:
		return 0.7  # Good
	elif closest_time <= ok_window:
		return 0.4  # OK
	else:
		return 0.0  # Miss

func register_rhythm_action(action_type: String) -> float:
	"""
	Call this when player performs an action that should be rhythm-timed
	Returns the damage multiplier based on timing
	"""
	var accuracy = check_rhythm_timing()

	if accuracy > 0.0:
		# Successful rhythm hit
		current_combo += 1
		combo_timer = combo_timeout

		if current_combo > max_combo:
			max_combo = current_combo

		combo_changed.emit(current_combo)

		# Calculate damage multiplier
		var damage_multiplier = 1.0
		if accuracy == 1.0:  # Perfect
			damage_multiplier = rhythm_damage_bonus
		elif accuracy >= 0.7:  # Good
			damage_multiplier = 1.2
		elif accuracy >= 0.4:  # OK
			damage_multiplier = 1.1

		# Add combo bonus
		damage_multiplier += (current_combo * combo_damage_bonus)

		print("Rhythm action! Accuracy: ", accuracy, " Combo: ", current_combo, " Damage: x", damage_multiplier)
		return damage_multiplier
	else:
		# Missed the beat
		_combo_break()
		return 1.0  # No bonus, but no penalty

func _combo_break() -> void:
	if current_combo > 0:
		print("Combo broken at ", current_combo)
		current_combo = 0
		combo_changed.emit(0)

func get_rhythm_color() -> Color:
	"""
	Returns a color based on current rhythm performance
	Used for visual feedback
	"""
	var timing = check_rhythm_timing()

	if timing == 1.0:
		return Color.GOLD  # Perfect
	elif timing >= 0.7:
		return Color.GREEN  # Good
	elif timing >= 0.4:
		return Color.YELLOW # OK
	else:
		return Color.WHITE  # Neutral/Miss

func get_beat_progress() -> float:
	"""
	Returns progress through current beat (0.0 to 1.0)
	Used for visual indicators
	"""
	if not is_rhythm_active:
		return 0.0
	return beat_timer / beat_interval

func is_near_beat() -> bool:
	"""
	Returns true if player is close to a beat
	Used for UI indicators
	"""
	var timing = check_rhythm_timing()
	return timing >= 0.4  # OK window or better

# Save/Load integration
func get_rhythm_data() -> Dictionary:
	return {
		"max_combo": max_combo,
		"bpm": bpm,
		"rhythm_damage_bonus": rhythm_damage_bonus,
		"combo_damage_bonus": combo_damage_bonus
	}

func load_rhythm_data(data: Dictionary) -> void:
	if data.has("max_combo"):
		max_combo = data.max_combo
	if data.has("bpm"):
		set_bpm(data.bpm)
	if data.has("rhythm_damage_bonus"):
		rhythm_damage_bonus = data.rhythm_damage_bonus
	if data.has("combo_damage_bonus"):
		combo_damage_bonus = data.combo_damage_bonus
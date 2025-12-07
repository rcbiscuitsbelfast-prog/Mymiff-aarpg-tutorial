extends Control

@onready var beat_indicator: TextureRect = $BeatIndicator
@onready var beat_bar: ProgressBar = $BeatBar
@onready var combo_label: Label = $ComboLabel
@onready var rhythm_status: Label = $RhythmStatus
@onready var perfect_indicator: TextureRect = $PerfectIndicator

# Beat indicator animation
var beat_pulse_tween: Tween
var target_beat_scale: float = 1.2
var beat_color_perfect: Color = Color.GOLD
var beat_color_good: Color = Color.GREEN
var beat_color_ok: Color = Color.YELLOW
var beat_color_neutral: Color = Color.WHITE

func _ready() -> void:
	# Hide initially if rhythm is not active
	modulate.a = 0.0

	# Connect to rhythm manager signals
	if RhythmManager:
		RhythmManager.rhythm_mode_changed.connect(_on_rhythm_mode_changed)
		RhythmManager.beat_hit.connect(_on_beat_hit)
		RhythmManager.combo_changed.connect(_on_combo_changed)

	# Update immediately if rhythm is already active
	if RhythmManager and RhythmManager.is_rhythm_active:
		_on_rhythm_mode_changed(true)

func _process(delta: float) -> void:
	if not RhythmManager or not RhythmManager.is_rhythm_active:
		return

	# Update beat progress bar
	var beat_progress = RhythmManager.get_beat_progress()
	if beat_bar:
		beat_bar.value = beat_progress * 100.0

	# Update beat indicator based on timing
	_update_beat_indicator()

	# Update combo display
	if combo_label:
		if RhythmManager.current_combo > 0:
			combo_label.text = "COMBO x" + str(RhythmManager.current_combo)
			combo_label.modulate = _get_combo_color()
		else:
			combo_label.text = ""

	# Update rhythm status
	if rhythm_status:
		rhythm_status.text = "BPM: " + str(RhythmManager.bpm)

func _update_beat_indicator() -> void:
	if not beat_indicator:
		return

	var timing = RhythmManager.check_rhythm_timing()
	var target_color = beat_color_neutral
	var target_scale = 1.0

	if timing == 1.0:  # Perfect
		target_color = beat_color_perfect
		target_scale = target_beat_scale
		if perfect_indicator:
			perfect_indicator.visible = true
	elif timing >= 0.7:  # Good
		target_color = beat_color_good
		target_scale = 1.1
	elif timing >= 0.4:  # OK
		target_color = beat_color_ok
		target_scale = 1.05
	else:
		if perfect_indicator:
			perfect_indicator.visible = false

	# Smooth color transition
	beat_indicator.modulate = beat_indicator.modulate.lerp(target_color, delta * 10.0)

	# Pulse animation
	if beat_pulse_tween:
		beat_pulse_tween.kill()

	beat_pulse_tween = create_tween()
	beat_pulse_tween.set_ease(Tween.EASE_OUT)
	beat_pulse_tween.set_trans(Tween.TRANS_BACK)
	beat_pulse_tween.tween_property(beat_indicator, "scale", Vector2(target_scale, target_scale), 0.1)
	beat_pulse_tween.tween_property(beat_indicator, "scale", Vector2.ONE, 0.2)

func _get_combo_color() -> Color:
	var combo = RhythmManager.current_combo
	if combo >= 20:
		return Color.GOLD
	elif combo >= 15:
		return Color.ORANGE
	elif combo >= 10:
		return Color.RED
	elif combo >= 5:
		return Color.CYAN
	else:
		return Color.WHITE

func _on_rhythm_mode_changed(is_active: bool) -> void:
	# Fade in/out the rhythm HUD
	var fade_tween = create_tween()
	fade_tween.set_ease(Tween.EASE_IN_OUT)

	if is_active:
		visible = true
		fade_tween.tween_property(self, "modulate:a", 1.0, 0.5)
	else:
		fade_tween.tween_property(self, "modulate:a", 0.0, 0.5)
		fade_tween.tween_callback(func(): visible = false)

func _on_beat_hit(beat_number: int, accuracy: float) -> void:
	# Pulse the beat indicator on beat
	if beat_indicator:
		var pulse_tween = create_tween()
		pulse_tween.set_ease(Tween.EASE_OUT)
		pulse_tween.set_trans(Tween.TRANS_BACK)
		pulse_tween.tween_property(beat_indicator, "scale", Vector2(1.3, 1.3), 0.05)
		pulse_tween.tween_property(beat_indicator, "scale", Vector2.ONE, 0.15)

	# Flash perfect indicator for perfect timing
	if perfect_indicator and accuracy == 1.0:
		perfect_indicator.modulate = Color.GOLD
		var flash_tween = create_tween()
		flash_tween.tween_property(perfect_indicator, "modulate:a", 1.0, 0.1)
		flash_tween.tween_property(perfect_indicator, "modulate:a", 0.0, 0.3)

func _on_combo_changed(combo_count: int) -> void:
	# Animate combo label change
	if combo_label and combo_count > 1:
		var combo_tween = create_tween()
		combo_tween.set_ease(Tween.EASE_OUT)
		combo_tween.set_trans(Tween.TRANS_BACK)
		combo_tween.tween_property(combo_label, "scale", Vector2(1.5, 1.5), 0.2)
		combo_tween.tween_property(combo_label, "scale", Vector2.ONE, 0.3)

	# Screen shake for high combos
	if combo_count > 0 and combo_count % 10 == 0:
		if PlayerManager:
			PlayerManager.shake_camera(combo_count * 2.0)

func show_timing_feedback(accuracy: float) -> void:
	# Show temporary feedback for action timing
	var feedback_label = Label.new()
	feedback_label.text = _get_timing_text(accuracy)
	feedback_label.add_theme_font_size_override("font_size", 24)
	feedback_label.modulate = _get_timing_color(accuracy)
	feedback_label.position = Vector2(240, 135) - feedback_label.size / 2  # Center screen
	add_child(feedback_label)

	# Animate and remove
	var feedback_tween = create_tween()
	feedback_tween.set_parallel(true)
	feedback_tween.tween_property(feedback_label, "position:y", feedback_label.position.y - 50, 0.8)
	feedback_tween.tween_property(feedback_label, "modulate:a", 0.0, 0.8)
	feedback_tween.tween_callback(feedback_label.queue_free)

func _get_timing_text(accuracy: float) -> String:
	if accuracy == 1.0:
		return "PERFECT!"
	elif accuracy >= 0.7:
		return "GOOD!"
	elif accuracy >= 0.4:
		return "OK"
	else:
		return "MISS"

func _get_timing_color(accuracy: float) -> Color:
	if accuracy == 1.0:
		return Color.GOLD
	elif accuracy >= 0.7:
		return Color.GREEN
	elif accuracy >= 0.4:
		return Color.YELLOW
	else:
		return Color.GRAY
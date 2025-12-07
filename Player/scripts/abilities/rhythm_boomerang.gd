extends "res://Player/scripts/abilities/boomerang.gd"

class_name RhythmBoomerang

# Rhythm-specific properties
var rhythm_power_multiplier: float = 1.0
var is_charged_by_rhythm: bool = false

func _ready() -> void:
	super._ready()
	# Connect to rhythm manager signals
	if RhythmManager:
		RhythmManager.beat_hit.connect(_on_beat_hit)

func _on_beat_hit(beat_number: int, accuracy: float) -> void:
	# Boost boomerang power on perfect beats
	if accuracy == 1.0 and is_active:
		rhythm_power_multiplier = 1.5
		is_charged_by_rhythm = true
		_create_rhythm_charge_effect()

func throw(direction: Vector2) -> void:
	if RhythmManager.is_rhythm_active:
		# Register rhythm action for throw
		var throw_multiplier = RhythmManager.register_rhythm_action("boomerang_throw")
		rhythm_power_multiplier = throw_multiplier

		# Enhanced throw effects based on timing
		if throw_multiplier >= 1.3:
			_create_perfect_throw_effect()
		elif throw_multiplier >= 1.1:
			_create_good_throw_effect()

	super.throw(direction)

func _create_rhythm_charge_effect() -> void:
	# Visual effect for rhythm charge
	var sparkle = preload("res://Effects/rhythm_sparkle.tscn").instantiate()
	if sparkle:
		get_tree().current_scene.add_child(sparkle)
		sparkle.global_position = player.global_position

func _create_perfect_throw_effect() -> void:
	# Enhanced visual effects for perfect timing
	var color = RhythmManager.get_rhythm_color()
	sprite.modulate = color

	# Create trail effect
	var trail = preload("res://Effects/boomerang_trail.tscn").instantiate()
	if trail:
		get_tree().current_scene.add_child(trail)
		trail.global_position = global_position
		trail.modulate = color

func _create_good_throw_effect() -> void:
	# Moderate visual effects for good timing
	sprite.modulate = Color.CYAN

func _physics_process(delta: float) -> void:
	super._physics_process(delta)

	# Apply rhythm power boost
	if is_charged_by_rhythm and velocity.length() > 0:
		velocity *= 1.1  # Slight speed boost

func deal_damage(area: Area2D) -> void:
	# Apply rhythm damage bonus
	var original_damage = damage
	damage = int(damage * rhythm_power_multiplier)

	super.deal_damage(area)

	# Reset damage
	damage = original_damage
	rhythm_power_multiplier = 1.0
	is_charged_by_rhythm = false

func return_to_player() -> void:
	# Enhanced return if caught on beat
	if RhythmManager.is_rhythm_active:
		var catch_timing = RhythmManager.check_rhythm_timing()
		if catch_timing >= 0.7:
			# Create burst effect on good catch
			_create_catch_effect()

	super.return_to_player()

func _create_catch_effect() -> void:
	# Visual effect for catching boomerang on beat
	if EffectManager:
		EffectManager.create_rhythm_catch_effect(player.global_position)
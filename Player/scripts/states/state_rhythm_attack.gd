extends StateAttack

class_name StateRhythmAttack

# Rhythm attack variables
var rhythm_window_start: float = 0.0
var is_rhythm_attack: bool = false
var attack_performed: bool = false

# Visual feedback
var attack_flash_color: Color = Color.GOLD
var attack_flash_duration: float = 0.2

func enter() -> void:
	super.enter()
	is_rhythm_attack = RhythmManager.is_rhythm_active
	attack_performed = false

	if is_rhythm_attack:
		# Visual indication that this is a rhythm attack
		rhythm_window_start = Time.get_time_dict_from_system()["second"]
		player.modulate = attack_flash_color

func process(delta: float) -> State:
	if not is_rhythm_attack:
		# Fall back to normal attack behavior
		return super.process(delta)

	# Rhythm attack logic
	if not attack_performed and Input.is_action_just_pressed("attack"):
		_perform_rhythm_attack()

	if attack_performed:
		# Wait for attack animation to finish
		if not animation_player.is_playing():
			return state_machine.states[0]  # Return to idle

	return null

func _perform_rhythm_attack() -> void:
	if attack_performed:
		return

	# Get rhythm timing accuracy
	var damage_multiplier = RhythmManager.register_rhythm_action("attack")

	# Apply damage multiplier to the attack
	var original_damage = player.hit_box.damage
	var rhythm_damage = int(original_damage * damage_multiplier)

	# Temporarily increase damage for this attack
	player.hit_box.damage = rhythm_damage

	# Play enhanced visual effects
	_play_rhythm_attack_effects(damage_multiplier)

	# Perform the actual attack
	super.attack()

	# Reset damage after attack
	attack_performed = true
	await get_tree().create_timer(0.1).timeout
	player.hit_box.damage = original_damage

func _play_rhythm_attack_effects(damage_multiplier: float) -> void:
	var rhythm_color = RhythmManager.get_rhythm_color()

	# Enhanced visual feedback
	player.sprite.modulate = rhythm_color

	# Create screen shake based on performance
	var shake_intensity = damage_multiplier - 1.0
	PlayerManager.shake_camera(shake_intensity * 10.0)

	# Create particles if available
	if EffectManager:
		EffectManager.create_rhythm_hit_effect(
			player.global_position,
			rhythm_color,
			damage_multiplier
		)

	# Play enhanced sound
	player.audio.pitch_scale = 1.0 + (damage_multiplier - 1.0) * 0.5
	player.audio.play()

func exit() -> void:
	super.exit()

	# Reset visual effects
	player.modulate = Color.WHITE
	player.sprite.modulate = Color.WHITE
	player.audio.pitch_scale = 1.0

func can_enter() -> bool:
	# Can enter rhythm attack if rhythm mode is active OR normal attack conditions
	return super.can_enter()
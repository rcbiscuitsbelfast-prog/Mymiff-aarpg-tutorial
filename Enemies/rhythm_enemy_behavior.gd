extends Node

# Rhythm-based enemy behavior component
# Can be added to any enemy to make them interact with rhythm mechanics

signal rhythm_stunned(duration: float)
signal rhythm_captured()
signal rhythm_weakened(strength: float)

@export var rhythm_vulnerable: bool = true
@export var stun_duration_per_beat: float = 0.5
@export var capture_beats_required: int = 3
@export var weakness_threshold: float = 0.7  # Rhythm accuracy needed to weaken

var current_rhythm_hits: int = 0
var is_rhythm_stunned: bool = false
var enemy_node: Node2D

func _ready() -> void:
	# Get the enemy parent node
	enemy_node = get_parent() as Node2D

	# Connect to rhythm manager if available
	if RhythmManager:
		RhythmManager.beat_hit.connect(_on_beat_hit)

func _on_beat_hit(beat_number: int, accuracy: float) -> void:
	if not rhythm_vulnerable or not enemy_node:
		return

	# Check if player is near and attacking
	var player = PlayerManager.player
	if not player or not _is_player_in_range(player):
		return

	# Check if player is performing rhythm attack
	if _is_player_attacking_on_beat():
		_apply_rhythm_effect(accuracy)

func _is_player_in_range(player: Node2D) -> bool:
	if not enemy_node:
		return false

	var distance = enemy_node.global_position.distance_to(player.global_position)
	return distance <= 100.0  # Adjust range as needed

func _is_player_attacking_on_beat() -> bool:
	# This would need to be integrated with the player's attack state
	# For now, assume player is attacking if rhythm window is good
	return RhythmManager.is_near_beat()

func _apply_rhythm_effect(accuracy: float) -> void:
	if accuracy >= weakness_threshold:
		current_rhythm_hits += 1

		# Visual feedback
		_show_rhythm_hit_effect(accuracy)

		# Apply effects based on accuracy
		if accuracy == 1.0:  # Perfect
			_perfect_beat_effect()
		elif accuracy >= 0.7:  # Good
			_good_beat_effect()
		else:  # OK
			_ok_beat_effect()

		# Check for capture
		if current_rhythm_hits >= capture_beats_required:
			_capture_enemy()
	else:
		# Miss the beat - reset progress
		current_rhythm_hits = 0

func _perfect_beat_effect() -> void:
	# Strong stun effect
	rhythm_stunned.emit(stun_duration_per_beat * 2.0)
	is_rhythm_stunned = true

	# Show visual feedback
	_create_perfect_effect()

	# Weaken enemy significantly
	rhythm_weakened.emit(1.5)

func _good_beat_effect() -> void:
	# Medium stun effect
	rhythm_stunned.emit(stun_duration_per_beat)
	is_rhythm_stunned = true

	# Moderate weakening
	rhythm_weakened.emit(1.2)

func _ok_beat_effect() -> void:
	# Minor effect - just weaken slightly
	rhythm_weakened.emit(1.1)

func _show_rhythm_hit_effect(accuracy: float) -> void:
	var color = RhythmManager.get_rhythm_color()

	# Create hit indicator
	var hit_indicator = preload("res://Effects/rhythm_hit_indicator.tscn").instantiate()
	if hit_indicator and enemy_node:
		get_tree().current_scene.add_child(hit_indicator)
		hit_indicator.global_position = enemy_node.global_position
		hit_indicator.modulate = color

	# Screen shake effect
	if PlayerManager:
		PlayerManager.shake_camera(accuracy * 5.0)

func _create_perfect_effect() -> void:
	# Special effect for perfect timing
	var stars = preload("res://Effects/perfect_stars.tscn").instantiate()
	if stars and enemy_node:
		get_tree().current_scene.add_child(stars)
		stars.global_position = enemy_node.global_position

func _capture_enemy() -> void:
	rhythm_captured.emit()
	current_rhythm_hits = 0

	# Create capture effect
	var capture_effect = preload("res://Effects/rhythm_capture_effect.tscn").instantiate()
	if capture_effect and enemy_node:
		get_tree().current_scene.add_child(capture_effect)
		capture_effect.global_position = enemy_node.global_position

	# Disable the enemy temporarily
	if enemy_node.has_method("disable_enemy"):
		enemy_node.disable_enemy()
	elif enemy_node.has_method("set_process"):
		enemy_node.set_process(false)

	# Remove the enemy after capture effect
	await get_tree().create_timer(2.0).timeout
	if enemy_node:
		enemy_node.queue_free()

func reset_rhythm_progress() -> void:
	current_rhythm_hits = 0
	is_rhythm_stunned = false

func get_rhythm_progress() -> float:
	return float(current_rhythm_hits) / float(capture_beats_required)

# Integration with existing enemy systems
func take_damage_with_rhythm(damage: int, is_rhythm_attack: bool = false) -> void:
	var modified_damage = damage

	if is_rhythm_attack and is_rhythm_stunned:
		# Extra damage to rhythm-stunned enemies
		modified_damage = int(damage * 1.5)

	if enemy_node and enemy_node.has_method("take_damage"):
		enemy_node.take_damage(modified_damage)
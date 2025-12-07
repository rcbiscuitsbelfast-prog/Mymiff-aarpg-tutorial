extends Node

const DAMAGE_TEXT = preload("res://00_Globals/global_effects/damage_text.tscn")
const RHYTHM_PULSE = preload("res://Effects/rhythm_pulse.tscn")
const RHYTHM_HIT = preload("res://Effects/rhythm_hit.tscn")

func damage_text( _damage : int, _pos : Vector2 ) -> void:
	var _t : DamageText = DAMAGE_TEXT.instantiate()
	add_child( _t )
	_t.start( str( _damage ), _pos )
	pass

# Rhythm effects
func create_rhythm_pulse() -> void:
	# Visual pulse effect on each beat
	if not RhythmManager or not RhythmManager.is_rhythm_active:
		return

	var pulse = RHYTHM_PULSE.instantiate()
	if pulse and PlayerManager and PlayerManager.player:
		get_tree().current_scene.add_child(pulse)
		pulse.global_position = PlayerManager.player.global_position

func create_rhythm_hit_effect(pos: Vector2, color: Color, intensity: float) -> void:
	# Enhanced hit effect for rhythm attacks
	var hit = RHYTHM_HIT.instantiate()
	if hit:
		get_tree().current_scene.add_child(hit)
		hit.global_position = pos
		hit.modulate = color
		hit.scale = Vector2.ONE * intensity

func create_rhythm_catch_effect(pos: Vector2) -> void:
	# Effect for catching items on beat
	var catch_effect = preload("res://Effects/rhythm_catch.tscn").instantiate()
	if catch_effect:
		get_tree().current_scene.add_child(catch_effect)
		catch_effect.global_position = pos

func create_rhythm_activation_effect(pos: Vector2) -> void:
	# Effect when rhythm mode is activated
	var activation_effect = preload("res://Effects/rhythm_activation.tscn").instantiate()
	if activation_effect:
		get_tree().current_scene.add_child(activation_effect)
		activation_effect.global_position = pos

func create_rhythm_stars_effect(pos: Vector2) -> void:
	# Special effect for perfect timing
	var stars = preload("res://Effects/perfect_stars.tscn").instantiate()
	if stars:
		get_tree().current_scene.add_child(stars)
		stars.global_position = pos

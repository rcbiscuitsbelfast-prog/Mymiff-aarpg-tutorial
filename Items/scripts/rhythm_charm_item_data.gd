extends "res://Items/scripts/equipable_item_data.gd"

class_name RhythmCharmItemData

@export var rhythm_bpm: float = 120.0
@export var duration_minutes: float = 5.0
@export var damage_bonus: float = 1.2

var active_timer: float = 0.0
var is_active: bool = false

func _ready() -> void:
	super._ready()
	item_name = "Rhythm Charm"
	item_type = "Accessory"
	description = "Enables rhythm combat mode. Attacks timed to the beat deal bonus damage."

func use_item(user: Node2D) -> bool:
	if not RhythmManager:
		return false

	if not is_active:
		# Activate rhythm mode
		_activate_rhythm_mode(user)
		return true
	else:
		# Deactivate rhythm mode
		_deactivate_rhythm_mode()
		return true

func _activate_rhythm_mode(user: Node2D) -> void:
	# Set the BPM for this charm
	RhythmManager.set_bpm(rhythm_bpm)

	# Apply damage bonus
	RhythmManager.rhythm_damage_bonus = damage_bonus

	# Start rhythm mode
	RhythmManager.start_rhythm_mode()

	# Set up timer for duration
	active_timer = duration_minutes * 60.0  # Convert to seconds
	is_active = true

	# Create activation effect
	if EffectManager:
		EffectManager.create_rhythm_activation_effect(user.global_position)

	# Show notification
	if PlayerHud and PlayerHud.has_method("show_notification"):
		PlayerHud.show_notification("Rhythm Mode Activated!")

	# Start the duration timer
	var timer = get_tree().create_timer(active_timer)
	timer.timeout.connect(_on_duration_expired)

func _deactivate_rhythm_mode() -> void:
	RhythmManager.stop_rhythm_mode()
	is_active = false
	active_timer = 0.0

	# Show notification
	if PlayerHud and PlayerHud.has_method("show_notification"):
		PlayerHud.show_notification("Rhythm Mode Deactivated")

func _on_duration_expired() -> void:
	if is_active:
		_deactivate_rhythm_mode()

func get_status_text() -> String:
	if not is_active:
		return "Click to activate rhythm mode"
	else:
		var remaining_minutes = int(active_timer / 60)
		var remaining_seconds = int(active_timer % 60)
		return "Active: %d:%02d" % [remaining_minutes, remaining_seconds]

# Save/Load support
func get_save_data() -> Dictionary:
	var data = super.get_save_data()
	data["is_active"] = is_active
	data["active_timer"] = active_timer
	return data

func load_save_data(data: Dictionary) -> void:
	super.load_save_data(data)
	if data.has("is_active"):
		is_active = data.is_active
	if data.has("active_timer"):
		active_timer = data.active_timer

	# Restart timer if it was active
	if is_active and active_timer > 0:
		var timer = get_tree().create_timer(active_timer)
		timer.timeout.connect(_on_duration_expired)
	elif is_active:
		# If timer expired while saved, deactivate
		_deactivate_rhythm_mode()
extends Control

@onready var tutorial_window: Control = $TutorialWindow
@onready var title_label: Label = $TutorialWindow/TitleLabel
@onready var content_label: RichTextLabel = $TutorialWindow/ContentLabel
@onready var continue_button: Button = $TutorialWindow/ContinueButton
@onready var beat_demo: TextureRect = $TutorialWindow/BeatDemo

var tutorial_steps: Array[String] = [
	"""
	[b][font_size=18]Welcome to Rhythm Combat![/font_size][/b]

	[font_size=14]Your ARPG now features rhythm-based mechanics![/font_size]

	• Press [color=gold]R[/color] to toggle rhythm mode
	• Time your attacks to the beat for bonus damage
	• Build combos by hitting consecutive beats
	• Capture enemies with rhythm attacks

	Press [color=cyan]Continue[/color] to learn the basics...
	""",
	"""
	[b][font_size=18]Understanding the Beat[/font_size][/b]

	[font_size=14]The beat indicator shows timing:[/font_size]

	• [color=gold]GOLD[/color] = Perfect timing (±100ms)
	• [color=green]GREEN[/color] = Good timing (±200ms)
	• [color=yellow]YELLOW[/color] = OK timing (±300ms)
	• [color=white]WHITE[/color] = Miss the beat

	[color=cyan]Try attacking when the indicator pulses![/color]
	""",
	"""
	[b][font_size=18]Damage Bonuses[/font_size][/b]

	[font_size=14]Rhythm timing affects your damage:[/font_size]

	• [color=gold]Perfect[/color]: 1.5x damage + combo bonus
	• [color=green]Good[/color]: 1.2x damage
	• [color=yellow]OK[/color]: 1.1x damage
	• [color=gray]Miss[/color]: Normal damage

	[color=cyan]Higher combos = more damage![/color]
	""",
	"""
	[b][font_size=18]Enemy Capture[/font_size][/b]

	[font_size=14]Some enemies are rhythm-vulnerable:[/font_size]

	• Hit them on the beat to build capture progress
	• Perfect timing stuns enemies longer
	• Fill the capture bar to defeat enemies instantly
	• Look for visual feedback when you hit the beat

	[color=cyan]Try capturing rhythm-enemies![/color]
	""",
	"""
	[b][font_size=18]Rhythm Abilities[/font_size][/b]

	[font_size=14]Your abilities benefit from rhythm:[/font_size]

	• [color=cyan]Boomerang[/color]: Throws faster on perfect beats
	• [color=cyan]Bow[/color]: Arrows fly straighter on rhythm
	• [color=cyan]Bombs[/color]: Larger explosion on perfect timing
	• [color=cyan]Dash[/color]: Longer dash on beat

	[color=cyan]Experiment with different abilities![/color]
	""",
	"""
	[b][font_size=18]Tips & Tricks[/font_size][/b]

	[font_size=14]Master the rhythm system:[/font_size]

	• Start with slower songs (lower BPM)
	• Watch the beat progress bar
	• Listen to the audio cues
	• Don't spam - wait for the right moment
	• Use the environment to your advantage

	[color=gold]Good luck, rhythm warrior![/color]
	"""
]

var current_step: int = 0
var is_visible: bool = false

func _ready() -> void:
	hide_tutorial()
	continue_button.pressed.connect(_on_continue_pressed)

	# Connect to rhythm manager for demo
	if RhythmManager:
		RhythmManager.beat_hit.connect(_on_beat_hit_for_demo)

func show_tutorial() -> void:
	current_step = 0
	is_visible = true
	visible = true
	tutorial_window.visible = true
	_update_tutorial_step()

func hide_tutorial() -> void:
	is_visible = false
	visible = false
	tutorial_window.visible = false

func _update_tutorial_step() -> void:
	if current_step >= tutorial_steps.size():
		hide_tutorial()
		return

	title_label.text = "Rhythm Tutorial - Step " + str(current_step + 1) + "/" + str(tutorial_steps.size())
	content_label.text = tutorial_steps[current_step]

	# Update button text
	if current_step == tutorial_steps.size() - 1:
		continue_button.text = "Finish Tutorial"
	else:
		continue_button.text = "Continue"

func _on_continue_pressed() -> void:
	current_step += 1
	_update_tutorial_step()

	# Play click sound if available
	if AudioManager and has_method("play_ui_sound"):
		play_ui_sound()

func _on_beat_hit_for_demo(beat_number: int, accuracy: float) -> void:
	if not is_visible or not beat_demo:
		return

	# Animate the beat demo indicator
	var demo_tween = create_tween()
	demo_tween.set_ease(Tween.EASE_OUT)
	demo_tween.set_trans(Tween.TRANS_BACK)

	if accuracy == 1.0:  # Perfect
		beat_demo.modulate = Color.GOLD
		demo_tween.tween_property(beat_demo, "scale", Vector2(1.3, 1.3), 0.1)
	elif accuracy >= 0.7:  # Good
		beat_demo.modulate = Color.GREEN
		demo_tween.tween_property(beat_demo, "scale", Vector2(1.2, 1.2), 0.1)
	elif accuracy >= 0.4:  # OK
		beat_demo.modulate = Color.YELLOW
		demo_tween.tween_property(beat_demo, "scale", Vector2(1.1, 1.1), 0.1)
	else:
		beat_demo.modulate = Color.WHITE

	demo_tween.tween_property(beat_demo, "scale", Vector2.ONE, 0.2)

func _input(event: InputEvent) -> void:
	if not is_visible:
		return

	# Allow closing with escape
	if event.is_action_pressed("ui_cancel"):
		hide_tutorial()

	# Allow skipping with space
	if event.is_action_pressed("ui_accept"):
		_on_continue_pressed()

# Static methods to show/hide tutorial
static func show_rhythm_tutorial() -> void:
	var tutorial = preload("res://GUI/rhythm_tutorial/rhythm_tutorial.tscn").instantiate()
	if tutorial:
		get_tree().current_scene.add_child(tutorial)
		tutorial.show_tutorial()
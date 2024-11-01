extends Control

var has_triggered: bool = false

@onready var label:RichTextLabel = (%Label as RichTextLabel)
@onready var container:PanelContainer = (%Container as PanelContainer)
@onready var animation_player:AnimationPlayer = (%AnimationPlayer as AnimationPlayer)
@export var is_reflective_text := false
@export var non_reflective_override_text := ""

func _ready() -> void:
  container.visible = false

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
  if has_triggered: return
  if non_reflective_override_text and Globals.hide_reflection_text:
    label.text = non_reflective_override_text
  if (is_reflective_text 
    and Globals.hide_reflection_text
    and not non_reflective_override_text): return
    
  container.visible = true
  animation_player.play("fade_in")
  has_triggered = true

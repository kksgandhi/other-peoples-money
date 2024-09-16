extends Control

var has_triggered: bool = false

@onready var label:RichTextLabel = (%Label as RichTextLabel)
@onready var animation_player:AnimationPlayer = (%AnimationPlayer as AnimationPlayer)

func _ready() -> void:
  label.visible = false

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
  if has_triggered: return
    
  label.visible = true
  animation_player.play("fade_in")
  has_triggered = true

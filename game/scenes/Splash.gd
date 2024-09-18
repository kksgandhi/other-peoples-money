extends Node2D

func _ready() -> void:
  if Globals.hide_reflection_text:
    $HideSplash.play("hide_splash")
  else:
    $ShowLabels.play("show_labels")
  visible = true

func _unhandled_input(event: InputEvent) -> void:
  if event is InputEventMouseButton and not $ShowLabels.is_playing():
    $HideSplash.play("hide_splash")
  if event.is_action_pressed("debug"):
      queue_free()
    
func _on_hide_splash_animation_finished(anim_name: String) -> void:
  queue_free() # Replace with function body.

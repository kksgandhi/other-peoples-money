extends Node2D

func _ready() -> void:
  visible = true

func _unhandled_input(event: InputEvent) -> void:
  if event is InputEventMouseButton and not $ShowLabels.is_playing():
    $HideSplash.play("hide_splash")
    
func _on_hide_splash_animation_finished(anim_name: String) -> void:
  queue_free() # Replace with function body.

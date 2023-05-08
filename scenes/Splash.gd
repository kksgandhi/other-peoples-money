extends Node2D

func _ready():
  visible = true

func _unhandled_input(event):
  if event is InputEventMouseButton:
    $HideSplash.play("hide_splash")
    
func _on_hide_splash_animation_finished(anim_name):
  queue_free() # Replace with function body.

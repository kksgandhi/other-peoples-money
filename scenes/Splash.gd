extends Node2D

func _ready():
  visible = true

func _unhandled_input(event):
  if event is InputEventMouseButton:
    $AnimationPlayer.play("splash_hide")


func _on_animation_player_animation_finished(anim_name):
  queue_free() # Replace with function body.
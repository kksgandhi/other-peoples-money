extends Panel
class_name Overlay

@export var animator: AnimationPlayer

func fade_in() -> void:
  animator.play("fade_in")

func fade_out() -> void:
  animator.play("fade_out")

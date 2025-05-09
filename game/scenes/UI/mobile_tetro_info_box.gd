extends PanelContainer
class_name MobileInfoTetroBox

@export var label: RichTextLabel
@export var animator: AnimationPlayer

func display(tetro_info: TetroInfo) -> void:
  label.text = tetro_info.title + "\n\n$" + Globals.comma_sep(tetro_info.cost)
  if animator.is_playing():
    animator.stop()
    animator.play("redisplay")
  else:
    animator.play("display")

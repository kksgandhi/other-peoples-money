extends VBoxContainer

var focused_child := 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
  if Input.is_action_just_pressed("down"):
    focused_child = (focused_child + 1) % get_child_count()
    refocus_child()
  elif Input.is_action_just_pressed("up"):
    focused_child = (focused_child - 1)
    # apparently modulo doesn't work
    if focused_child < 0:
      focused_child += get_child_count()
    refocus_child()


func refocus_child() -> void:
  var child_to_focus: Control = get_child(focused_child)
  # wonderfully miserable and hacky hardcoding
  child_to_focus.get_node("Button").grab_focus()

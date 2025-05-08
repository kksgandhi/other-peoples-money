extends TextureButton

enum ButtonType {
  ROTATE,
  UP,
  DOWN,
  LEFT,
  RIGHT }

@export var buttonType := ButtonType.ROTATE

var hot := false
func _process(delta: float) -> void:
  if button_pressed:
    hot = true
    var ev := InputEventAction.new()
    ev.pressed = true
    match buttonType:
      ButtonType.ROTATE:
        ev.action = "rotate"
      ButtonType.UP:
        ev.action = "mobile_up"
      ButtonType.DOWN:
        ev.action = "mobile_down"
      ButtonType.LEFT:
        ev.action = "left"
      ButtonType.RIGHT:
        ev.action = "right"
    Input.parse_input_event(ev)
  elif hot:
    hot = false
    for action_type: String in ["rotate", "left", "right"]:
      var ev := InputEventAction.new()
      ev.action = action_type
      ev.pressed = false
      Input.parse_input_event(ev)

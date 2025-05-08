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
    match buttonType:
      ButtonType.ROTATE:
        var ev := InputEventAction.new()
        ev.action = "rotate"
        ev.pressed = true
        Input.parse_input_event(ev)
      ButtonType.UP:
        print("UP")
      ButtonType.DOWN:
        print("DOWN")
      ButtonType.LEFT:
        var ev := InputEventAction.new()
        ev.action = "left"
        ev.pressed = true
        Input.parse_input_event(ev)
      ButtonType.RIGHT:
        var ev := InputEventAction.new()
        ev.action = "right"
        ev.pressed = true
        Input.parse_input_event(ev)
  elif hot:
    hot = false
    for action_type: String in ["rotate", "left", "right"]:
      var ev := InputEventAction.new()
      ev.action = action_type
      ev.pressed = false
      Input.parse_input_event(ev)

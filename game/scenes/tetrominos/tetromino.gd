class_name Tetromino
extends CharacterBody2D

signal is_clicked

func _process(delta: float) -> void:
  handle_movement()

var downspeed := 300
func calculate_down_velocity() -> void:
  velocity.y = downspeed

@export var strafespeed := 150
func calculate_strafe_velocity() -> void:
  if Input.is_action_pressed("left"):
    velocity.x = -strafespeed
  elif Input.is_action_pressed("right"):
    velocity.x = strafespeed
  else:
    velocity.x = 0

var is_frozen := false
var is_grounded := false
var tetro_info: TetroInfo

func handle_movement() -> void:
  if is_frozen: return
  calculate_down_velocity()
  calculate_strafe_velocity()
  handle_rotation()
  move_and_slide()
  if velocity.y == 0:
    # velocity is zero? We must have hit the ground
    # or the top of another tetromino
    # freeze this tetromino in place then
    is_grounded = true

func handle_rotation() -> void:
  if Input.is_action_just_pressed("rotate"):
    rotation_degrees += 90
    
func set_color(color: Color) -> void:
  %Sprite2D.modulate = Color(color)
  
func set_tooltips(text: String) -> void:
  for child: Control in $Tooltips.get_children():
    child.tooltip_text = str(text)
    child.gui_input.connect(handle_mouse_event)
    child.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
    
func handle_mouse_event(event: InputEvent) -> void:
  if event is InputEventMouseButton and event.pressed:
    is_clicked.emit()

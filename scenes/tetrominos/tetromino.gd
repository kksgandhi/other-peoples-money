extends CharacterBody2D


func _process(delta):
  handle_movement()

@export var downspeed := 100
func calculate_down_velocity():
  velocity.y = downspeed

@export var strafespeed := 150
func calculate_strafe_velocity():
  if Input.is_action_pressed("left"):
    velocity.x = -strafespeed
  elif Input.is_action_pressed("right"):
    velocity.x = strafespeed
  else:
    velocity.x = 0

var is_frozen := false
func handle_movement():
  if is_frozen: return
  calculate_down_velocity()
  calculate_strafe_velocity()
  handle_rotation()
  move_and_slide()
  if velocity.y == 0:
    # velocity is zero? We must have hit the ground
    # or the top of another tetromino
    # freeze this tetromino in place then
    pass # is_frozen = true

func handle_rotation():
  if Input.is_action_just_pressed("rotate"):
    rotation_degrees += 90
    
func set_color(color):
  %Sprite2D.modulate = Color(color)
  
func set_tooltips(text):
  $Tooltips.get_children().map(func(child): child.tooltip_text = text)

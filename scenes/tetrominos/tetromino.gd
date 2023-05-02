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
  move_and_slide()
  if velocity.y == 0:
    # velocity is zero? We must have hit the ground
    # or the top of another tetromino
    # freeze this tetromino in place then
    is_frozen = true


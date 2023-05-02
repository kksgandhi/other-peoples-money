extends Node2D

const tetromino_scene = preload("res://scenes/tetrominos/tetromino_s.tscn")

func _input(event):
  handle_spawn_tetromino(event)

func handle_spawn_tetromino(event):
  if event.is_action_pressed("debug"):
    var spawned_tetromino = tetromino_scene.instantiate()
    %tetrominos.add_child(spawned_tetromino)
    spawned_tetromino.position = %SpawnLocation.position
    spawned_tetromino.scale = Vector2(32, 32)

func _process(_delta):
  move_upwards_as_tetrominos_fall()

@export var breaking_position = 400
@export var game_movement_offset = 500
@export var camera_move_speed := 0.1
func move_upwards_as_tetrominos_fall():
  var highest_tetromino_y_position = 810
  for tetromino in %tetrominos.get_children():
    if tetromino.is_frozen and tetromino.position.y < highest_tetromino_y_position:
      highest_tetromino_y_position = tetromino.position.y
  if highest_tetromino_y_position < breaking_position:
    var desired_offset = highest_tetromino_y_position - game_movement_offset
    %CameraDestination.position.y = %OriginalCameraDestination.position.y + desired_offset
    %SpawnLocation.position.y = %OriginalSpawnLocation.position.y + desired_offset
  %MainCamera.position = lerp(%MainCamera.position, %CameraDestination.position, camera_move_speed)

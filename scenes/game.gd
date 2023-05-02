extends Node2D

const tetromino_scene = preload("res://scenes/tetrominos/tetromino_s.tscn")

var cost_information

var rng = RandomNumberGenerator.new()

func _ready():
  var file = FileAccess.open("res://assets/data/cost_information.json", FileAccess.READ)
  var text = file.get_as_text()
  cost_information = JSON.parse_string(text)
  file.close()

func _input(event):
  handle_spawn_tetromino(event)

func handle_spawn_tetromino(event):
  if event.is_action_pressed("debug") and cost_information.size() > 0:
    var tetromino_cost = float(cost_information.pop_at(rng.randi_range(0, cost_information.size() - 1)).cost)
    var spawned_tetromino = tetromino_scene.instantiate()
    %tetrominos.add_child(spawned_tetromino)
    spawned_tetromino.position = %SpawnLocation.position
    spawned_tetromino.scale = Vector2(sqrt(tetromino_cost), sqrt(tetromino_cost))
    print(tetromino_cost)

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

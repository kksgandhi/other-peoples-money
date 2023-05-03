extends Node2D

var cost_information

var rng = RandomNumberGenerator.new()


@onready var height_of_play_area = (Globals.top_400_wealth \
                 / 1000 # since we're working in thousands of dollars\
                 / Globals.thousands_of_dollars_per_pixel # divide by per pixel amount\
                 / %Bottom.scale.x) # divide by size of area
                
func _ready():
  read_cost_information()
  print(height_of_play_area)
  %Top.position.y = %Bottom.position.y - (height_of_play_area + 16)

func read_cost_information():
  var file = FileAccess.open("res://assets/data/cost_information.json", FileAccess.READ)
  var text = file.get_as_text()
  cost_information = JSON.parse_string(text)
  file.close()

func _input(event):
  # handle_spawn_tetromino(event)
  add_tetro_ui_item(event)

var tetro_choice_item = preload("res://scenes/tetrominos/tetro_choice_item.tscn")
func add_tetro_ui_item(event):
  if event.is_action_pressed("debug") and cost_information.size() > 0:
    var choice_item_instance = tetro_choice_item.instantiate()
    %tetro_choices.add_child(choice_item_instance)
    var tetromino_information = cost_information.pop_at(rng.randi_range(0, cost_information.size() - 1))
    choice_item_instance.update_displayed_information(tetromino_information)
    choice_item_instance.selected.connect(ui_item_selected)
    
func ui_item_selected(tetro_info, child):
  %tetrominos.get_children().map(func(child): child.is_frozen = true)
  spawn_tetromino(tetro_info)
  child.queue_free()

func is_tetromino_topped_out():
  return %Top.get_overlapping_bodies()\
              .any(func(body): return not body.is_in_group('wall'))


func spawn_tetromino(tetro_info):
  # const tetromino_scene = preload("res://scenes/tetrominos/tetromino_s.tscn")
  var spawned_tetromino = load("res://scenes/tetrominos/" + tetro_info.sprite + ".tscn").instantiate()
  %tetrominos.add_child(spawned_tetromino)
  spawned_tetromino.position = %SpawnLocation.position
  spawned_tetromino.scale = Vector2(1, 1) * Globals.get_tetromino_scale(tetro_info.cost)
  spawned_tetromino.set_color(tetro_info.color)
  spawned_tetromino.set_tooltips(spawned_tetromino.scale)

func _process(_delta):
  move_upwards_as_tetrominos_fall()
  handle_disable_sidebar()

func handle_disable_sidebar():
  var all_tetrominos_bottomed_out = %tetrominos.get_children()\
                                        .all(func(child): return child.velocity.y == 0)
  var sidebar_disabled = is_tetromino_topped_out() or not all_tetrominos_bottomed_out
  %tetro_choices.get_children().map(func(choice_item_child): choice_item_child.get_node("Button").disabled = sidebar_disabled)

@export var breaking_position = 400
@export var game_movement_offset = 500
@export var camera_move_speed := 0.1

func move_upwards_as_tetrominos_fall():
  var highest_tetromino_y_position = 810
  for tetromino in %tetrominos.get_children():
    if tetromino.is_grounded and tetromino.position.y < highest_tetromino_y_position:
      highest_tetromino_y_position = tetromino.position.y
  if highest_tetromino_y_position < breaking_position:
    var desired_offset = highest_tetromino_y_position - game_movement_offset
    desired_offset = max(desired_offset, %Top.position.y - %Top.scale.y / 2)
    %CameraDestination.position.y = %OriginalCameraDestination.position.y + desired_offset
    %SpawnLocation.position.y = %OriginalSpawnLocation.position.y + desired_offset
    %MainCamera.position = lerp(%MainCamera.position, %CameraDestination.position, camera_move_speed)

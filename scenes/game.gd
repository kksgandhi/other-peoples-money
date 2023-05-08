extends Node2D

var cost_information

var rng = RandomNumberGenerator.new()


@onready var height_of_play_area = (Globals.top_400_wealth \
                 / 1000 # since we're working in thousands of dollars\
                 / Globals.thousands_of_dollars_per_pixel # divide by per pixel amount\
                 / %Bottom.scale.x) # divide by size of area
                
func _ready():
  read_cost_information()
  add_tetro_ui_item(); add_tetro_ui_item(); add_tetro_ui_item(); add_tetro_ui_item(); add_tetro_ui_item()
  %Top.position.y = %Bottom.position.y - (height_of_play_area + 16)

func read_cost_information():
  var file = FileAccess.open("res://assets/data/cost_information.json", FileAccess.READ)
  var text = file.get_as_text()
  var raw_cost_information = JSON.parse_string(text)
  cost_information = raw_cost_information.map(func(info): info.cost = info.cost * 1000000; return info)
  file.close()

func _unhandled_input(event):
  if event.is_action_pressed("debug"):
    handle_debug()
  handle_scroll(event)

@export var scroll_speed = 100
@export var unlocked_camera_speed = 0.5
var is_camera_locked = true
func handle_scroll(event):
  #TODO do not hard-code the next line
  if event is InputEventMouseButton and event.is_pressed() and get_global_mouse_position().x < 1030:
    if event.button_index == MOUSE_BUTTON_WHEEL_UP:
      %CameraDestination.position.y = %MainCamera.position.y - scroll_speed
      is_camera_locked = false
    if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
      %CameraDestination.position.y = %MainCamera.position.y + scroll_speed
      is_camera_locked = false
  %CameraDestination.position.y = clamp(%CameraDestination.position.y,
                                        %OriginalCameraDestination.position.y + desired_offset,
                                        %OriginalCameraDestination.position.y)
  if %CameraDestination.position.y == %OriginalCameraDestination.position.y + desired_offset:
    is_camera_locked = true
  

var tetro_choice_item = preload("res://scenes/tetrominos/tetro_choice_item.tscn")
func add_tetro_ui_item():
  if cost_information.size() > 0:
    var choice_item_instance = tetro_choice_item.instantiate()
    %tetro_choices.add_child(choice_item_instance)
    var tetromino_information = cost_information.pop_at(rng.randi_range(0, cost_information.size() - 1))
    choice_item_instance.update_displayed_information(tetromino_information)
    choice_item_instance.selected.connect(ui_item_selected)
    
func ui_item_selected(tetro_info, child):
  %tetrominos.get_children().map(func(child): child.is_frozen = true)
  spawn_tetromino(tetro_info)
  child.queue_free()
  add_tetro_ui_item()

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
  spawned_tetromino.set_tooltips(tetro_info.title)

  remaining_wealth -= tetro_info.cost * 1000

func _process(_delta):
  move_upwards_as_tetrominos_fall()
  handle_disable_sidebar()
  handle_leftsidebar_end_message()

func handle_disable_sidebar():
  var all_tetrominos_bottomed_out = %tetrominos.get_children()\
                                        .all(func(child): return child.velocity.y == 0)
  var sidebar_disabled = is_tetromino_topped_out() or not all_tetrominos_bottomed_out
  %tetro_choices.get_children().map(func(choice_item_child): choice_item_child.get_node("Button").disabled = sidebar_disabled)

@export var breaking_position = 400
@export var game_movement_offset = 500
@export var camera_move_speed := 0.1

var highest_tetromino_y_position = 100000000
var desired_offset := 0.0
var is_broken := false
var has_leftsidebar_animation_played = false
func move_upwards_as_tetrominos_fall():
  # find the highest tetromino (by center)
  for tetromino in %tetrominos.get_children():
    if tetromino.is_frozen and tetromino.position.y < highest_tetromino_y_position:
      highest_tetromino_y_position = tetromino.position.y

  # if this position is higher than the breaking position, start moving the camera
  if highest_tetromino_y_position < breaking_position:
    is_broken = true
    desired_offset = highest_tetromino_y_position - game_movement_offset
    desired_offset = max(desired_offset, %Top.position.y - %Top.scale.y / 2)
    if not has_leftsidebar_animation_played and desired_offset == %Top.position.y - %Top.scale.y / 2:
      %LeftSideBarAnimationPlayer.play("fade_left_texts")
      %LeftSideBarEndText.visible = true
      has_leftsidebar_animation_played = true

    %SpawnLocation.position.y = %OriginalSpawnLocation.position.y + desired_offset
    if is_camera_locked:
      %CameraDestination.position.y = %OriginalCameraDestination.position.y + desired_offset

  var current_camera_move_speed = camera_move_speed if is_camera_locked else unlocked_camera_speed
  %MainCamera.position = lerp(%MainCamera.position, %CameraDestination.position, current_camera_move_speed)

@onready var remaining_wealth = Globals.top_400_wealth
@onready var original_leftsidebar_end_text = %LeftSideBarEndText.text
func handle_leftsidebar_end_message():
  %LeftSideBarEndText.text = original_leftsidebar_end_text + " Each of our original 400 richest americans still has (on average) $" + Globals.comma_sep(remaining_wealth / 400) + " — an amount that would take the average American " + Globals.comma_sep(int(remaining_wealth / 400 / 1700000)) + " lifetimes to earn.\n\n\nIt would be silly to think that we could just take money from billionaires and throw it at our problems, but this is just a game after all. Regardless, I hope this got you thinking about actual solutions. Thanks for playing."

func handle_debug():
  #%LeftSideBarEndText.visible = true
  #%LeftSideBarAnimationPlayer.play("fade_left_texts")
  # %LeftSideBarText.visible=true
  print(is_camera_locked)
  pass


func _on_left_side_bar_text_meta_clicked(meta):
  print(meta)
  OS.shell_open(str(meta))

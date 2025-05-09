extends Node2D

var cost_information: Array[TetroInfo]

var rng := RandomNumberGenerator.new()
@onready var top := %Top as Area2D
@onready var bottom := %Bottom as StaticBody2D
@onready var camera_destination := %CameraDestination as Marker2D
@onready var main_camera := %MainCamera as Camera2D
@onready var original_camera_destination := %OriginalCameraDestination as Marker2D
@onready var spawn_location := %SpawnLocation as Marker2D
@onready var original_spawn_location := %OriginalSpawnLocation as Marker2D
@onready var block_instructions_fader := %block_instructions_fade_in if !Globals.is_mobile else %mobile_block_instructions_fade_in as AnimationPlayer
@onready var scroll_instructions_fader := %scroll_instructions_fader if !Globals.is_mobile else %mobile_scroll_instructions_fader as AnimationPlayer
@onready var tetro_choices := %tetro_choices as VBoxContainer
@onready var tetrominos := %tetrominos as Node2D
@onready var info_overlay := %InfoOverlay as Overlay
@onready var spending_overlay := %SpendingOverlay as Overlay
@onready var spending_info := %SpendingInfo as SpendingInfo
@onready var sidebar_top_label := %sidebar_top_label as Label

var have_block_instructions_faded_in := false
var have_scroll_instructions_faded_in := false

@onready var height_of_play_area: float = (Globals.top_400_wealth \
                 / Globals.dollars_per_pixel # divide by per pixel amount\
                 / (bottom.scale.x * 8)) # divide by the width of the play area. We multiply by 8: the default sprite is already scaled by 8, so the "scale" value is off by a factor of 8.
                
func _ready() -> void:
  read_cost_information()
  add_tetro_ui_item(); add_tetro_ui_item(); add_tetro_ui_item(); add_tetro_ui_item(); add_tetro_ui_item()
  top.position.y = bottom.position.y - (height_of_play_area + 16)
  if Globals.is_mobile:
    scroll_speed = scroll_speed / 7

func cost_info_to_resource(info: Dictionary) -> TetroInfo:
  return TetroInfo.new(Vector2(1, 1), Color.WHITE, info.title, "", info.cost * 1_000_000_000)

func read_cost_information() -> void:
  var file := FileAccess.open("res://assets/data/cost_information.json", FileAccess.READ)
  var text := file.get_as_text()
  var raw_cost_information: Array = JSON.parse_string(text)
  cost_information.assign(raw_cost_information.map(cost_info_to_resource))
  file.close()

func _unhandled_input(event: InputEvent) -> void:
  if event.is_action_pressed("debug"):
    handle_debug()
  handle_scroll(event)

@export var scroll_speed := 100
@export var unlocked_camera_speed := 0.5
var is_camera_locked := true
func handle_scroll(event: InputEvent) -> void:
  #TODO do not hard-code the next line
  var desktop_scroll := event is InputEventMouseButton and event.is_pressed() and get_global_mouse_position().x < 1030
  var overlay_visible := spending_overlay.visible or info_overlay.visible
  var mobile_up := event.is_action_pressed("mobile_up")
  var mobile_down := event.is_action_pressed("mobile_down")
  var mobile_scroll := mobile_up or mobile_down
  if (desktop_scroll or mobile_scroll) and not overlay_visible:
    var mouse_event := event as InputEventMouseButton
    var up := mobile_up or (not mobile_scroll and mouse_event.button_index == MOUSE_BUTTON_WHEEL_UP)
    var down := mobile_down or (not mobile_scroll and mouse_event.button_index == MOUSE_BUTTON_WHEEL_DOWN)
    if up:
      camera_destination.position.y = main_camera.position.y - scroll_speed
      is_camera_locked = false
    if down:
      camera_destination.position.y = main_camera.position.y + scroll_speed
      is_camera_locked = false
  camera_destination.position.y = clamp(camera_destination.position.y,
                                        original_camera_destination.position.y + desired_offset,
                                        original_camera_destination.position.y)
  if camera_destination.position.y == original_camera_destination.position.y + desired_offset and not has_leftsidebar_animation_played:
    is_camera_locked = true
  

var tetro_choice_item := preload("res://scenes/tetrominos/tetro_choice_item.tscn")
func add_tetro_ui_item() -> void:
  if cost_information.size() > 0:
    var choice_item_instance := tetro_choice_item.instantiate() as TetroChoiceItem
    tetro_choices.add_child(choice_item_instance)
    var tetromino_information: TetroInfo = cost_information.pop_at(rng.randi_range(0, cost_information.size() - 1))
    choice_item_instance.update_displayed_information(tetromino_information)
    choice_item_instance.selected.connect(ui_item_selected)
    choice_item_instance.selected.connect(spending_info.update)
    
func ui_item_selected(tetro_info: TetroInfo, child: TetroChoiceItem) -> void:
  tetrominos.get_children().map(func(tet_child: Tetromino) -> void: tet_child.is_frozen = true)
  spawn_tetromino(tetro_info)
  child.queue_free()
  add_tetro_ui_item()

func is_tetromino_topped_out() -> bool:
  return top.get_overlapping_bodies()\
      .any(func(body: Node) -> bool: return not body.is_in_group('wall'))
      
var is_first_tetromino := true
func spawn_tetromino(tetro_info: TetroInfo) -> void:
  var spawned_tetromino := (load("res://scenes/tetrominos/" + tetro_info.sprite + ".tscn") as PackedScene).instantiate() as Tetromino
  %tetrominos.add_child(spawned_tetromino)
  spawned_tetromino.position = spawn_location.position
  # make the first tetromino take longer to fall, 
  # that way players are more likely to look at the instructions
  if is_first_tetromino:
    is_first_tetromino = false
    spawned_tetromino.position += Vector2.UP * 800
  spawned_tetromino.scale = Vector2(1, 1) * Globals.get_tetromino_scale(tetro_info.cost)
  spawned_tetromino.set_color(tetro_info.color)
  spawned_tetromino.tetro_info = tetro_info
  spawned_tetromino.is_clicked.connect(func() -> void: info_overlay.fade_in())
  var tooltip := tetro_info.title + " $" + Globals.comma_sep(tetro_info.cost) if Globals.hide_cost else tetro_info.title
  spawned_tetromino.set_tooltips(tooltip)

  remaining_wealth -= tetro_info.cost * 1_000

  if not have_block_instructions_faded_in:
    have_block_instructions_faded_in = true
    block_instructions_fader.play("fade_in")

func _process(delta: float) -> void:
  move_upwards_as_tetrominos_fall()
  handle_disable_sidebar(delta)
  handle_leftsidebar_end_message()

var sidebar_disabled_time := 0.0
func handle_disable_sidebar(delta: float) -> void:
  var all_tetrominos_bottomed_out := %tetrominos.get_children()\
      .all(func(child: Tetromino) -> bool: return child.velocity.y == 0)
  var sidebar_disabled := is_tetromino_topped_out() or not all_tetrominos_bottomed_out
  tetro_choices.get_children().map(func(choice_item_child: TetroChoiceItem) -> void: choice_item_child.button.disabled = sidebar_disabled)
  if sidebar_disabled:
    sidebar_disabled_time += delta
    if sidebar_disabled_time > 6:
      if is_tetromino_topped_out():
        sidebar_top_label.text = "You've reached the top.\n Can you do more, or is this it?"
      if not all_tetrominos_bottomed_out:
        sidebar_top_label.text = "A block is stuck. Try rotating."

  else:
    sidebar_disabled_time = 0
    sidebar_top_label.text = "Choose a topic below."

@export var breaking_position := 10
@export var game_movement_offset := 10
@export var camera_move_speed := 0.1

var highest_tetromino_y_position := 100_000_000.0
var desired_offset := 0.0
var is_broken := false
var has_leftsidebar_animation_played := false
var has_end_spending_info_been_shown := false

func move_upwards_as_tetrominos_fall() -> void:
  # find the highest tetromino (by center)
  for tetromino: Tetromino in tetrominos.get_children():
    if tetromino.is_frozen and tetromino.position.y < highest_tetromino_y_position:
      highest_tetromino_y_position = tetromino.position.y

  # if this position is higher than the breaking position, start moving the camera
  if highest_tetromino_y_position < breaking_position:
    is_broken = true
    desired_offset = highest_tetromino_y_position - game_movement_offset
    #desired_offset = max(desired_offset, top.position.y - top.scale.y / 2)
    if desired_offset < top.position.y - top.scale.y / 2:
      desired_offset = top.position.y - top.scale.y / 2
      if not has_end_spending_info_been_shown:
        _on_spending_button_pressed()
        has_end_spending_info_been_shown = true
        camera_move_speed = camera_move_speed * 3 # TODO don't hardcode
    #if not has_leftsidebar_animation_played and desired_offset == top.position.y - top.scale.y / 2:
      #%LeftSideBarAnimationPlayer.play("fade_left_texts")
      #%LeftSideBarEndText.visible = true
      #has_leftsidebar_animation_played = true

    spawn_location.position.y = original_spawn_location.position.y + desired_offset
    if is_camera_locked:
      camera_destination.position.y = original_camera_destination.position.y + desired_offset

    if not have_scroll_instructions_faded_in:
      have_scroll_instructions_faded_in = true
      scroll_instructions_fader.play("fade_in")

  var current_camera_move_speed := camera_move_speed if is_camera_locked else unlocked_camera_speed
  main_camera.position = lerp(main_camera.position, camera_destination.position, current_camera_move_speed)

@onready var remaining_wealth := Globals.top_400_wealth
@onready var original_leftsidebar_end_text: String = %LeftSideBarEndText.text
func handle_leftsidebar_end_message() -> void:
  %LeftSideBarEndText.text = original_leftsidebar_end_text + " Each of our original 400 richest americans still has (on average) $" + Globals.comma_sep(int(remaining_wealth / 400.0)) + " — an amount that would take the average American " + Globals.comma_sep(int(remaining_wealth / 400.0 / 1700000.0)) + " lifetimes to earn.\n\n\nIt would be silly to think that we could just take money from billionaires and throw it at our problems, but this is just a game after all. Regardless, I hope this got you thinking about actual solutions. Thanks for playing."

func handle_debug() -> void:
  #%LeftSideBarEndText.visible = true
  #%LeftSideBarAnimationPlayer.play("fade_left_texts")
  # %LeftSideBarText.visible=true
  pass


func _on_left_side_bar_text_meta_clicked(meta: Variant) -> void:
  print(meta)
  OS.shell_open(str(meta))


func _on_info_button_pressed() -> void:
  info_overlay.fade_in()


func _on_spending_button_pressed() -> void:
  spending_overlay.fade_in()

extends PanelContainer

var rng = RandomNumberGenerator.new()

signal selected(tetromino_info)
var tetromino_resources = ["tetromino_i", "tetromino_j", "tetromino_l", "tetromino_o", "tetromino_s", "tetromino_t", "tetromino_z"]
var tetromino_information: Dictionary
var colors = ["#77dd77", "#836953", "#89cff0", "#99c5c4", "#9adedb", "#aa9499", "#aaf0d1", "#b2fba5", "#b39eb5", "#bdb0d0", "#bee7a5", "#befd73", "#c1c6fc", "#c6a4a4", "#c8ffb0", "#cb99c9", "#cef0cc", "#cfcfc4", "#d6fffe", "#d8a1c4", "#dea5a4", "#deece1", "#dfd8e1", "#e5d9d3", "#e9d1bf", "#f49ac2", "#f4bfff", "#fdfd96", "#ff6961", "#ff964f", "#ff9899", "#ffb7ce", "#ca9bf7"]

func update_displayed_information(input_tetromino_information):
  tetromino_information = input_tetromino_information
  %TetrominoIcon.custom_minimum_size = %TetrominoIcon.texture.get_size() * Globals.get_tetromino_scale(input_tetromino_information.cost)
  var tetromino_texture = tetromino_resources[rng.randi() % tetromino_resources.size()]
  %TetrominoIcon.texture = load("res://assets/images/" + tetromino_texture + ".png")
  tetromino_information.sprite = tetromino_texture
  %TetrominoTitle.clear()
  %TetrominoTitle.append_text(tetromino_information.title)
  %TetrominoTitle.append_text("\n$")
  %TetrominoTitle.append_text(Globals.comma_sep(tetromino_information.cost * 1000))
  var color_choice = colors[rng.randi() % colors.size()]
  %TetrominoIcon.modulate = Color(color_choice)
  tetromino_information.color = color_choice
  $Button.tooltip_text = input_tetromino_information.more_information

func _on_button_pressed():
  selected.emit(tetromino_information, self) # Replace with function body.

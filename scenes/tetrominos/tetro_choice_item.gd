extends PanelContainer

var rng = RandomNumberGenerator.new()

signal selected(tetromino_info)
var tetromino_resources = ["tetromino_i", "tetromino_j", "tetromino_l", "tetromino_o", "tetromino_s", "tetromino_t", "tetromino_z"]
var tetromino_information: Dictionary
var colors = ["#f1077d", "#e33a31", "#b56400", "#767c00", "#158618", "#00895f"]

func update_displayed_information(input_tetromino_information):
  tetromino_information = input_tetromino_information
  %TetrominoIcon.custom_minimum_size = %TetrominoIcon.texture.get_size() * sqrt(tetromino_information.cost)
  var tetromino_texture = tetromino_resources[rng.randi() % tetromino_resources.size()]
  %TetrominoIcon.texture = load("res://assets/images/" + tetromino_texture + ".png")
  tetromino_information.sprite = tetromino_texture
  %TetrominoTitle.clear()
  %TetrominoTitle.append_text(tetromino_information.title)
  var color_choice = colors[rng.randi() % colors.size()]
  %TetrominoIcon.modulate = Color(color_choice)
  tetromino_information.color = color_choice



func _on_button_pressed():
  selected.emit(tetromino_information, self) # Replace with function body.

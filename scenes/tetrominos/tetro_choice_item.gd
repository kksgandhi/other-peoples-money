extends PanelContainer

signal selected(tetromino_info)

var tetromino_information: Dictionary
func update_displayed_information(input_tetromino_information):
  tetromino_information = input_tetromino_information
  %TetrominoIcon.custom_minimum_size = %TetrominoIcon.texture.get_size() * sqrt(tetromino_information.cost)
  %TetrominoTitle.clear()
  %TetrominoTitle.append_text(tetromino_information.title)



func _on_button_pressed():
  selected.emit(tetromino_information, self) # Replace with function body.

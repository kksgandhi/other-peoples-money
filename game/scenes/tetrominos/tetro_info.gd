extends Resource
class_name TetroInfo

var scale: Vector2
var color: Color
var title: String
var sprite: String
var cost: int

func _init(_scale: Vector2, _color: Color, _title: String, _sprite: String, _cost: int) -> void:
  scale = _scale
  color = _color
  title = _title
  sprite = _sprite
  cost = _cost

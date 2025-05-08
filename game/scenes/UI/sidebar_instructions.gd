extends Node2D

@export var mobile_instructions := false

func _ready() -> void:
  visible = Globals.is_mobile == mobile_instructions

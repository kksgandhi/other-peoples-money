extends Node2D

const tetromino = preload("res://scenes/tetrominos/tetromino_s.tscn")


func _input(event):
  if event.is_action_pressed("debug"):
    var spawned_tetromino = tetromino.instantiate()
    %tetrominos.add_child(spawned_tetromino)
    spawned_tetromino.position = %SpawnLocation.position
    spawned_tetromino.scale = Vector2(32, 32)

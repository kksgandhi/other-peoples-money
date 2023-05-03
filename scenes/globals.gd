extends Node

var thousands_of_dollars_per_pixel = 10000.0 / 4.0

var top_400_wealth = 4000000000000.0

func get_tetromino_scale(cost):
  return sqrt(float(cost) / thousands_of_dollars_per_pixel / 4.0)

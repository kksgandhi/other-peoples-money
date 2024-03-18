extends Node

var thousands_of_dollars_per_pixel := 10_000.0 / 4.0

var top_400_wealth := 4_000_000_000_000.0

func get_tetromino_scale(cost: float) -> float:
  return sqrt(float(cost) / thousands_of_dollars_per_pixel / 4.0)

func comma_sep(number: int) -> String:
    var string := str(number)
    var mod := string.length() % 3
    var res := ""

    for i in range(0, string.length()):
        if i != 0 && i % 3 == mod:
            res += ","
        res += string[i]

    return res

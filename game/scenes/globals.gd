extends Node

var dollars_per_pixel := 10_000_000.0 / 4.0

var top_400_wealth := 4_000_000_000_000.0

var hide_cost := true

var hide_reflection_text := true

var debug_mobile := false
var is_mobile := debug_mobile or OS.has_feature("web_android") or OS.has_feature("web_ios")

var research_telemetry := true

var research_id := ""

func get_tetromino_scale(cost: float) -> float:
  return sqrt(float(cost) / dollars_per_pixel / 4.0)

func comma_sep(number: int) -> String:
    var string := str(number)
    var mod := string.length() % 3
    var res := ""

    for i in range(0, string.length()):
        if i != 0 && i % 3 == mod:
            res += ","
        res += string[i]

    return res

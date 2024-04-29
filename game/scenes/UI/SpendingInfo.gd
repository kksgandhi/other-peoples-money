extends RichTextLabel
class_name SpendingInfo

var tetro_infos: Array[TetroInfo] = []
@export_multiline var base_text: String

func sorter(info1: TetroInfo, info2: TetroInfo) -> bool:
  return info1.cost > info2.cost

func update(tetro_info: TetroInfo, child: TetroChoiceItem) -> void:
  tetro_infos.append(tetro_info)
  tetro_infos.sort_custom(sorter)

  var total_cost: float = 0.0
  for info in tetro_infos:
    total_cost += info.cost

  text = ""

  text += "You've spent $"
  text += Globals.comma_sep(roundi(total_cost / 1_000_000_000.0))
  text += " billion so far, "
  text += str(snapped(total_cost / Globals.top_400_wealth, 0.01) * 100.0)
  text += "% of the wealth of the richest 400. They each still have $"
  text += Globals.comma_sep(roundi((Globals.top_400_wealth - total_cost) / 400 / 1_000_000_000.0))
  text += " billion.\n\n"
  text += base_text
  text += "\n\n"

  for info in tetro_infos:
    text += info.title
    text += "\n$"
    text += Globals.comma_sep(roundi(info.cost / 1_000_000.0))
    text += "M\n\n"



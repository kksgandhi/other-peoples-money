extends RichTextLabel
class_name SpendingInfo

var tetro_infos: Array[TetroInfo] = []
@export_multiline var base_text: String

func sorter(info1: TetroInfo, info2: TetroInfo) -> bool:
  return info1.cost > info2.cost

func update(tetro_info: TetroInfo, child: TetroChoiceItem) -> void:
  tetro_infos.append(tetro_info)
  tetro_infos.sort_custom(sorter)

  text = ""
  text += base_text
  text += "\n\n"

  for info in tetro_infos:
    text += info.title
    text += "\n$"
    text += Globals.comma_sep(roundi(info.cost / 1_000_000.0))
    text += "M\n\n"



extends Node2D

@export_subgroup("Animators")
@export var show_labels : AnimationPlayer
@export var hide_splash : AnimationPlayer
@export var research_animator : AnimationPlayer
@export_subgroup("Research Children")
@export var research_label : Label
@export var research_id_text_edit : TextEdit

# Are we done with the splash screen?
# Yes, if research telemetry is not active and we are hiding the reflection text
# Otherwise this will get set later in this script
var splash_flow_finished := not Globals.research_telemetry and Globals.hide_reflection_text

func _ready() -> void:
  visible = true
  if Globals.research_telemetry:
    research_animator.play("show_research")
  else:
    start_game_flow()

func start_game_flow() -> void:
  if Globals.hide_reflection_text:
    hide_splash.play("hide_splash")
  else:
    show_labels.play("show_labels")

func _unhandled_input(event: InputEvent) -> void:
  if event is InputEventMouseButton and splash_flow_finished:
    hide_splash.play("hide_splash")
  if event.is_action_pressed("debug"):
    queue_free()

func _on_hide_splash_animation_finished(anim_name: String) -> void:
  queue_free()

func _on_research_continue_button_pressed() -> void:
  # TODO: validate research_id_text
  print(research_id_text_edit.text)
  research_animator.play("hide_research")
  start_game_flow()

func _on_show_labels_animation_finished(anim_name: StringName) -> void:
  splash_flow_finished = true

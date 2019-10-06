extends Control

export var scene : PackedScene

func _on_start_button():
    get_tree().change_scene_to(scene)

func _input(event):
    if event.is_action_pressed("ui_select"):
        _on_start_button()

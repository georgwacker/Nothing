extends Node

export var scene : PackedScene

func next_scene():
    get_tree().change_scene_to(scene)
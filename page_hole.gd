class_name PageHole
extends Area2D

func _init() -> void:
	set_collision_layer_value(2, true)
	set_collision_mask_value(2, true)

func get_page() -> Page:
	return get_parent()

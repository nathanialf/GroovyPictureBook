@tool

class_name PageWall
extends StaticBody2D

func _process(delta: float) -> void:
	var page := get_page()
	if page:
		for child in get_children():
			if child is Polygon2D:
				child.color = page.page_color

func get_page() -> Page:
	return get_parent()

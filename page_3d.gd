class_name Page3D
extends Node3D

@export var page_scene: PackedScene
var page: Page

func _ready() -> void:
	assert(page_scene, "Page3D needs a page scene!")
	
	page = page_scene.instantiate()
	$SubViewport.add_child(page)

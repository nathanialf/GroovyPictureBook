extends Node3D

@export var book_cover: Node3D
@export var target_cover_pos = 160.0

var cover_pos = 160.0
var inital_pos = Vector3()
var inital_rot = Vector3()

func _ready() -> void:
	inital_pos = book_cover.position
	inital_rot = book_cover.rotation

func _process(delta: float) -> void:
	book_cover.rotation = inital_rot
	
	cover_pos = lerp(cover_pos, target_cover_pos, delta*2.0)
	
	book_cover.rotate_object_local(Vector3(0,0,1), cover_pos/57.295)

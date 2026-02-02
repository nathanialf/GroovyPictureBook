extends MeshInstance3D

@export var materials: Array[Mater]

var time = 0.0

func _process(delta: float) -> void:
	time+=delta
	
	set_surface_override_material()

extends MeshInstance3D

@export var colors: Array[Vector3]

var time = 0.0

func _process(delta: float) -> void:
	time+=delta
	
	

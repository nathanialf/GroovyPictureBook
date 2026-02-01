extends Node3D

@export var pins: Array[Node3D]
@export var label: Label3D
@export var pickup_dist = 1.0

func _process(delta: float) -> void:
	var pin_num = 0
	
	for pin in pins:
		if pin != null:
			if pin.inside:
				pin_num+=1
				
			pin.pickup_dist = pickup_dist
	
	label.text = str(pin_num)

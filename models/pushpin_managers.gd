extends Node3D

@export var pins: Array[Node3D]
@export var pickup_dist = 1.0
@export var ui_pins: Array[TextureRect]

func _process(delta: float) -> void:
	var pin_num = 0
	
	for pin in pins:
		if pin != null:
			if pin.inside:
				pin_num+=1
				
			pin.pickup_dist = pickup_dist
	
	for pin_index in range(ui_pins.size()):
		if ui_pins[pin_index] != null:
			if pin_index<pin_num:
				ui_pins[pin_index].position.y = 29.0
			else: 
				ui_pins[pin_index].position.y = -129.0

extends Node3D

@export var pins: Array[Node3D]
@export var pickup_dist = 1.0
@export var ui_pins: Array[TextureRect]
@export var player: Node3D
@export var edge_obj: Node3D
@export var edge_obj_dist := 1.0

var finished = false
var remove_time = 0.0
var inital_pos = Vector3()
var inital_rot = Vector3()

func _ready() -> void:
	inital_pos = edge_obj.position
	inital_rot = edge_obj.rotation
	
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
	
	if pin_num==0:
		var diff_vec = Vector2(player.position.x, player.position.y) - Vector2(edge_obj.position.x, edge_obj.position.y)
		var diff = diff_vec.length()
		
		if diff < edge_obj_dist:
			finished = true
		
	if finished:
		remove_time += delta + clamp((remove_time/1000.0), 0.0, delta*2)
		
		var shake_amt = (sin(remove_time*25)+(sin(remove_time*55.3253)/2.0)) * \
										 (sqrt(remove_time/2.0)/10.0)
		
		var pop_amt = 0
		
		if remove_time>2.0:
			var offset_time = remove_time-2.0
			
			pop_amt = -offset_time*15.0
			
			var pop_y_i = ((2*offset_time) - 0.707)
			var pop_y = -(pop_y_i*pop_y_i)+0.5
			
			edge_obj.position = inital_pos + Vector3(offset_time,pop_y,0)
			
		
		edge_obj.rotation = Vector3(0,0,shake_amt+pop_amt)
		

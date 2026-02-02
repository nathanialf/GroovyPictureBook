extends Node3D

@export var player: Node3D
var pickup_dist = 1.0
var inside = true
var remove_time = 0.0
var inital_pos = Vector3()
var inital_rot = Vector3()
var drop_pos = 0.0

var __played_pickup_sound := false

func _ready() -> void:
	inital_pos = position
	inital_rot = rotation
	
func _process(delta: float) -> void:
	var diff_vec = Vector2(player.position.x, player.position.y) - Vector2(position.x, position.y)
	
	var diff = diff_vec.length()

	if diff < pickup_dist:
		inside = false
		if !__played_pickup_sound:
			SFX.get_host(self).play_at_position_3d(SFX.PICKUP, global_position)
			__played_pickup_sound = true
		
	if !inside:
		remove_time += delta
		drop_pos += remove_time/20.0
		position.y = inital_pos.y - drop_pos
		position.z = inital_pos.z + (drop_pos/2.0)
		rotation = inital_rot + Vector3(drop_pos*2.0, 0, 0)
		
	if remove_time > 2.0:
		print_debug()
		queue_free()

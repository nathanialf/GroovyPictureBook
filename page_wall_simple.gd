@tool

class_name PageWallSimple
extends PageWall

var __polygon: Polygon2D
var __collision: CollisionShape2D

func _init() -> void:
	var start_size := Vector2(100, 20)
	var half_size := start_size / 2.0
	
	__polygon = Polygon2D.new()
	__polygon.polygon = PackedVector2Array([
		Vector2(-half_size.x, -half_size.y),
		Vector2(half_size.x, -half_size.y),
		Vector2(half_size.x, half_size.y),
		Vector2(-half_size.x, half_size.y)
	])
	add_child(__polygon)

	__collision = CollisionShape2D.new()
	__collision.shape = RectangleShape2D.new()
	__collision.shape.size = start_size
	add_child(__collision)

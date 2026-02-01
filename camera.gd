extends Camera3D

@onready var __player: Node3D = $"../PlayerSprite"
@onready var __x_target_anim: TargetAnimation = $XTargetAnimation
@onready var __y_target_anim: TargetAnimation = $YTargetAnimation
@onready var __orig_offset := Vector2(position.x, position.y)
var __offset: Vector2

func _ready() -> void:
	__x_target_anim.updated.connect(
		func(value: float): position.x = value
	)
	__y_target_anim.updated.connect(
		func(value: float): position.y = value
	)
	__offset = __orig_offset

var __did_first_move := false

func notify_moved_player() -> void:
	if !__did_first_move:
		__x_target_anim.snap_to(__player.position.x + __offset.x)
		__y_target_anim.snap_to(__player.position.y + __offset.y)
		position.x = __x_target_anim.current
		position.y = __y_target_anim.current
		__did_first_move = true
	__x_target_anim.target = __player.position.x + __offset.x
	__y_target_anim.target = __player.position.y + __offset.y

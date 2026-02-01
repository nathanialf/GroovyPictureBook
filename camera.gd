extends Camera3D

@onready var __player: Node3D = $"../PlayerSprite"
@onready var __x_target_anim: TargetAnimation = $XTargetAnimation
@onready var __y_target_anim: TargetAnimation = $YTargetAnimation
@onready var __orig_offset := Vector2(position.x, position.y)
var __offset: Vector2

@export var main_menu_target: Node3D
@export var game_target: Node3D
@export var book_cover: Node3D

func _ready() -> void:
	__x_target_anim.updated.connect(
		func(value: float): position.x = value
	)
	__y_target_anim.updated.connect(
		func(value: float): position.y = value
	)
	__offset = __orig_offset

var __did_first_move := false

func notify_moved_player(delta) -> void:
	if !__did_first_move:
		__x_target_anim.snap_to(__player.position.x + __offset.x)
		__y_target_anim.snap_to(__player.position.y + __offset.y)
		position.x = __x_target_anim.current
		position.y = __y_target_anim.current
		__did_first_move = true
	__x_target_anim.target = __player.position.x + __offset.x
	__y_target_anim.target = __player.position.y + __offset.y
	
func lerp_main_angle(delta) -> void:
	position = lerp(position, main_menu_target.position, delta*1.5)
	rotation = lerp(rotation, main_menu_target.rotation, delta*1.5)
	
func jump_main_angle(delta) -> void:
	position = main_menu_target.position
	rotation = main_menu_target.rotation
	
func lerp_game_angle(delta) -> void:
	position = lerp(position, game_target.position, delta*1.5)
	rotation = lerp(rotation, game_target.rotation, delta*1.5)

extends CharacterBody2D

@export var gravity_acceleration := 50.0
@export var move_speed := 600
@export var jump_force := 1000

var player_animator: AnimationTree 
var player_obj: Node 

@onready var page: Page = get_parent()

var jump_animation_reset = 0.0
var turn_animation_reset = 0.0
var player_angle = 90.0
var player_angle_target = 90.0

func _ready() -> void:
	page.is_active_page_changed.connect(
		func(is_active_page: bool):
			if is_active_page: __activate_player()
			else: __deactivate_player()
	)
	(func():
		if page.is_active_page: __activate_player()
		else: __deactivate_player()
	).call_deferred()

	player_obj = get_node("/root/Game/PlayerSprite/character_run")
	player_animator = player_obj.get_node("AnimationTree")

func _physics_process(delta: float) -> void:
	var move_input := Input.get_vector(\
		"Move left", "Move right", "Nothing", "Nothing")
	velocity.x = move_input.x * move_speed
	
	var movement_speed = clamp(abs(velocity.x)/600.0, 0.0, 1.0)
	player_animator.set("parameters/StateMachine/BlendTree/Blend2/blend_amount", movement_speed)
	
	if velocity.x > 0.1:
		player_angle_target = 90
	elif velocity.x < -0.1:
		player_angle_target = -90
	
	if abs(player_angle - player_angle_target) > 0.1:
		if player_angle_target > player_angle:
			player_angle = clamp((player_angle + delta*700.0), -90.0, 90.0)
		if player_angle_target < player_angle:
			player_angle = clamp((player_angle - delta*700.0), -90.0, 90.0)
		if abs(player_angle + 90) > 90.0:
			player_animator.set("parameters/StateMachine/conditions/turn", true)
			turn_animation_reset = 0.1
		
	player_obj.rotation = Vector3(0.0, player_angle/57.29, 0.0)
		
	jump_animation_reset -= delta
	turn_animation_reset -= delta
	
	if turn_animation_reset < 0.0:
		player_animator.set("parameters/StateMachine/conditions/turn", false)

	if jump_animation_reset < 0.0:
		player_animator.set("parameters/StateMachine/conditions/jump_start", false)
	else:
		player_animator.set("parameters/StateMachine/conditions/jump_end", false)
		
	if !is_on_floor():
		velocity.y += gravity_acceleration
	else:
		player_animator.set("parameters/StateMachine/conditions/jump_end", true)
		player_animator.set("parameters/StateMachine/conditions/jump_start", false)
		
	
	if Input.is_action_just_pressed("Jump") && is_on_floor():
		velocity.y = -jump_force
		player_animator.set("parameters/StateMachine/conditions/jump_start", true)
		player_animator.set("parameters/StateMachine/conditions/jump_end", false)
		jump_animation_reset = 0.1
	
	move_and_slide()

func __activate_player() -> void:
	if !get_parent(): page.add_child(self)

func __deactivate_player() -> void:
	if get_parent(): page.remove_child(self)

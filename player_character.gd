extends CharacterBody2D

@export var gravity_acceleration := 50.0
@export var sliding_acceleration := 35.0
@export var move_speed := 600
@export var jump_force := 1200
@export var wall_jump_force := Vector2(1100,900)
@export var movement_weight_air := 5.0
@export var movement_weight_ground := 5.0
@export var can_double_walljump := true
@export var hang_time_ms := 1000

var player_animator: AnimationTree 
var player_obj: Node 

@onready var page: Page = get_parent()

var jump_animation_reset = 0.0
var turn_animation_reset = 0.0
var player_angle = 90.0
var player_angle_target = 90.0
var wall_jump_period = 0.0
var in_air_timer = 0.0
var hang_time_expiration = 0.0

var can_walljump_left = true
var can_walljump_right = true

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
		
	var walljump_move_restrict = clamp((wall_jump_period)*-5.0, 0.0, 1.0)
	velocity.x += (move_input.x * (move_speed*page.get_move_speed_scalar())*0.3*walljump_move_restrict)	
	
	var movement_speed = clamp(abs(velocity.x)/300.0, 0.0, 1.0)
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
	wall_jump_period -= delta
	in_air_timer -= delta

	if in_air_timer > 0.01:
		player_animator.set("parameters/StateMachine/conditions/in_air", true)
		player_animator.set("parameters/StateMachine/conditions/jump_end", false)
	else:
		player_animator.set("parameters/StateMachine/conditions/in_air", false)
		player_animator.set("parameters/StateMachine/conditions/jump_end", false)

	if wall_jump_period < 0:
		player_animator.set("parameters/StateMachine/conditions/jump_off", false)
	
	if turn_animation_reset < 0.0:
		player_animator.set("parameters/StateMachine/conditions/turn", false)

	if jump_animation_reset < 0.0:
		player_animator.set("parameters/StateMachine/conditions/jump_start", false)
	else:
		player_animator.set("parameters/StateMachine/conditions/jump_end", false)

	if can_double_walljump:
		can_walljump_left=true
		can_walljump_right=true

	var space_state = get_world_2d().direct_space_state
	var left_wall_query = PhysicsRayQueryParameters2D.create(position, position + Vector2(-40.0, 0.0))
	var left_wall_result = space_state.intersect_ray(left_wall_query)
	var walljump_left_emable = can_walljump_left && left_wall_result
	var right_wall_query = PhysicsRayQueryParameters2D.create(position, position + Vector2(40.0, 0.0))
	var right_wall_result = space_state.intersect_ray(right_wall_query)
	var walljump_right_emable = can_walljump_right && right_wall_result
	
	if !is_on_floor():		
		if (left_wall_result or right_wall_result) and velocity.y > 0:
			velocity.y += sliding_acceleration 
		else:
			if !__is_hang_time():
				velocity.y += gravity_acceleration
			else:
				velocity.y = 0
				velocity.x = 0
			
		if in_air_timer < 0.0:
			in_air_timer = 0.0
		in_air_timer += delta*2.0
	else:
		player_animator.set("parameters/StateMachine/conditions/in_air", false)
		player_animator.set("parameters/StateMachine/conditions/jump_end", true)
		player_animator.set("parameters/StateMachine/conditions/jump_start", false)

	if wall_jump_period < 0:
		if is_on_floor():
			velocity.x *= (1-(delta*movement_weight_ground))
		else:
			velocity.x *= (1-(delta*movement_weight_air))
			
		velocity.x = clamp(velocity.x, -move_speed, move_speed)
	else: 
		if is_on_floor():
			velocity.x *= (1-(delta*movement_weight_ground/2.0))
		else:
			velocity.x *= (1-(delta*movement_weight_air/2.0))

	if is_on_floor():
		can_walljump_left = true
		can_walljump_right = true
		
		player_animator.set("parameters/StateMachine/conditions/wall_hug_right", false)
		player_animator.set("parameters/StateMachine/conditions/wall_hug", false)
	else:
		#print_debug(left_wall_result)
		if left_wall_result:
			player_animator.set("parameters/StateMachine/conditions/wall_hug", true)
			player_angle_target = -90
		elif right_wall_result:
			player_animator.set("parameters/StateMachine/conditions/wall_hug", true)
			player_angle_target = 90
		else:
			player_animator.set("parameters/StateMachine/conditions/wall_hug_right", false)
			player_animator.set("parameters/StateMachine/conditions/wall_hug", false)
		
	if (not left_wall_result) and (not right_wall_result):
		player_animator.set("parameters/StateMachine/conditions/clear_walljump", true)
	else:
		player_animator.set("parameters/StateMachine/conditions/clear_walljump", false)

	if Input.is_action_just_pressed("Jump") && is_on_floor():
		velocity.y = -jump_force
		player_animator.set("parameters/StateMachine/conditions/jump_start", true)
		player_animator.set("parameters/StateMachine/conditions/jump_end", false)
		jump_animation_reset = 0.1

	elif Input.is_action_just_pressed("Jump") && (walljump_left_emable || walljump_right_emable):
		if walljump_left_emable:
			velocity = wall_jump_force
			velocity.y *= -1.0
			can_walljump_left = false
			can_walljump_right = true
		else:
			velocity = wall_jump_force
			velocity.x *= -1.0
			velocity.y *= -1.0
			can_walljump_left = true
			can_walljump_right = false
		
		player_animator.set("parameters/StateMachine/conditions/jump_off", true)
		player_animator.set("parameters/StateMachine/conditions/wall_hug", false)
		player_animator.set("parameters/StateMachine/conditions/wall_hug_right", false)
		jump_animation_reset = 0.1
		wall_jump_period = 0.1
	
	move_and_slide()
	
	if position.x < 0 or position.y < 0 or position.x > 1920 or position.y > 1080:
		print("DEATH")

func __activate_player() -> void:
	if !get_parent(): page.add_child(self)

func __deactivate_player() -> void:
	if get_parent(): page.remove_child(self)
	
func on_page_flip() -> void:
	hang_time_expiration = Time.get_ticks_msec() + hang_time_ms

func __is_hang_time() -> bool:
	return !Time.get_ticks_msec() > hang_time_expiration

extends CharacterBody2D

@export var move_speed := 600
@export var jump_force := 1000

func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	var gravity := 50
	var move_input := Input.get_vector(\
		"Move left", "Move right", "Nothing", "Nothing")
	velocity.x = move_input.x * move_speed
	
	if !is_on_floor():
		velocity.y += gravity
	
	if Input.is_action_just_pressed("Jump") && is_on_floor():
		print(is_on_floor())
		velocity.y = -jump_force
	
	move_and_slide()

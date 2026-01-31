extends CharacterBody2D

func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	var gravity := 50
	var move_input := Input.get_vector(\
		"Move left", "Move right", "Nothing", "Nothing")
	velocity.x = move_input.x * 600.0
	
	if !is_on_floor():
		velocity.y += gravity
	
	if Input.is_action_just_pressed("Jump") && is_on_floor():
		print(is_on_floor())
		velocity.y = -1000
	
	move_and_slide()

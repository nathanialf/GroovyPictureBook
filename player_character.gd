extends CharacterBody2D

@export var gravity_acceleration := 50.0
@export var move_speed := 600
@export var jump_force := 1000

@onready var page: Page = get_parent()

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

func _physics_process(delta: float) -> void:
	var move_input := Input.get_vector(\
		"Move left", "Move right", "Nothing", "Nothing")
	velocity.x = move_input.x * move_speed
	
	if !is_on_floor():
		velocity.y += gravity_acceleration
	
	if Input.is_action_just_pressed("Jump") && is_on_floor():
		velocity.y = -jump_force
	
	move_and_slide()

func __activate_player() -> void:
	if !get_parent(): page.add_child(self)

func __deactivate_player() -> void:
	if get_parent(): page.remove_child(self)

extends Node3D

enum State { MAIN_MENU, CAMERA_ZOOM_IN, GAME, CAMERA_ZOOM_OUT, END }

var active_page_index: int = 0
var active_page: Page:
	set(value):
		if value != active_page:
			active_page_changing.emit(value)
			active_page = value
			active_page_changed.emit(value)
signal active_page_changing(page: Page)
signal active_page_changed(page: Page)

var game_state: State = State.MAIN_MENU
var sfx_host := SFX.new()
var transition_time = 0.0

@export var book_cover: Node3D
@export var pushpin_manager: Node3D
@export var start_text: Control
@export var end_text: Control

func _ready() -> void:
	active_page_changing.connect(
		func(new_active_page: Page):
			var prev_active_page := active_page
			if prev_active_page: 
				prev_active_page.is_active_page = false
			new_active_page.is_active_page = true
	)
	
	active_page = __all_pages()[active_page_index]
	__refresh_page_positions()
	
	add_child(sfx_host)
	sfx_host.sfx_placement_requested.connect(
		func(node_to_place: Node3D, position_2d: Vector2):
			var pos_3d := __pos2d_to_pos3d(position_2d)
			add_child(node_to_place)
			if position_2d != sfx_host.NO_POSITION:
				node_to_place.position = Vector3(pos_3d.x, pos_3d.y, 0.0)
	)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Page forward"):
		if __player_is_near_forward_hole():
			__flip_page_by(1)
	elif Input.is_action_just_pressed("Page backward"):
		if __player_is_near_backward_hole():
			__flip_page_by(-1)
	
	if Input.is_key_pressed(Key.KEY_R):
		get_tree().change_scene_to_file("res://game.tscn")
	
	var player_pos_2d := active_page.get_player_state().position
	var player_pos_3d := __pos2d_to_pos3d(player_pos_2d)
	$PlayerSprite.position.x = player_pos_3d.x
	$PlayerSprite.position.y = player_pos_3d.y
	if game_state == State.MAIN_MENU:
		$Camera3D.jump_main_angle(delta)
		book_cover.target_cover_pos = 160.0
		start_text.show()
		end_text.hide()
		
		if Input.is_action_just_pressed("Jump"):
			game_state = State.CAMERA_ZOOM_IN
			transition_time = 4.0
	if game_state == State.CAMERA_ZOOM_IN:
		$Camera3D.lerp_game_angle(delta)
		book_cover.target_cover_pos = 20.0
		transition_time -= delta
		start_text.hide()
		end_text.hide()
		
		if transition_time < 0:
			game_state = State.GAME
	if game_state == State.GAME:
		$Camera3D.notify_moved_player(delta)
		book_cover.target_cover_pos = 20.0
		start_text.hide()
		end_text.hide()
		
		if pushpin_manager.finished:
			game_state = State.CAMERA_ZOOM_OUT
			transition_time = 10.0
	if game_state == State.CAMERA_ZOOM_OUT:
		if transition_time > 7:
			book_cover.target_cover_pos = 20.0
			$Camera3D.notify_moved_player(delta)
		else:
			book_cover.target_cover_pos = 160.0
			$Camera3D.lerp_main_angle(delta)
		transition_time -= delta
		start_text.hide()
		end_text.hide()
		
		if transition_time < 0:
			game_state = State.END
	if game_state == State.END:
		$Camera3D.jump_main_angle(delta)
		start_text.hide()
		end_text.show()

func __player_is_near_forward_hole() -> bool:
	var test_page := active_page
	return test_page.test_is_near_hole()

func __player_is_near_backward_hole() -> bool:
	if active_page_index == 0: return false
	var test_page := __all_pages()[active_page_index - 1]
	return test_page.test_is_near_hole()

func __pos2d_to_pos3d(pos2d: Vector2) -> Vector2:
	# TODO lol
	return pos2d / Vector2(1000, -1000)

func __refresh_page_positions() -> void:
	var page3ds := __all_page3ds()
	for page_i in page3ds.size():
		var page3d: Page3D = page3ds[page_i]
		var page := page3d.page
		page.page_index = page_i
		var page_spacing := 0.25
		var page_z := (page_i - active_page_index) * -page_spacing
		const flipped_page_z := -1
		var page_y: float
		if (page_i - active_page_index) < 0: page_y = flipped_page_z
		else: page_y = 0
		var z_target_anim: TargetAnimation
		var y_target_anim: TargetAnimation
		if page3d.has_meta("z_target_anim"):
			z_target_anim = page3d.get_meta("z_target_anim")
			y_target_anim = page3d.get_meta("y_target_anim")
		else:
			z_target_anim = TargetAnimation.new()
			z_target_anim.config = load("res://page_z_spring.tres")
			z_target_anim.updated.connect(
				func(value: float):
					page3d.position.z = value
			)
			add_child(z_target_anim)
			page3d.set_meta("z_target_anim", z_target_anim)
			y_target_anim = TargetAnimation.new()
			y_target_anim.config = load("res://page_y_spring.tres")
			y_target_anim.updated.connect(
				func(value: float):
					page3d.position.y = value
					const max_rot := flipped_page_z / 5.0
					var rot: float
					if value > max_rot:
						rot = remap(value, 0, flipped_page_z / 5.0, 0, PI / 2.0)
					else:
						rot = PI / 2.0
					page3d.rotation.x = rot
			)
			add_child(y_target_anim)
			page3d.set_meta("y_target_anim", y_target_anim)
		z_target_anim.target = page_z
		y_target_anim.target = page_y

func __flip_page_by(amount: int) -> bool:
	var pages := __all_pages()
	var current_page_index := pages.find(active_page)
	if current_page_index == -1: return false
	var new_page_index := current_page_index + amount
	if new_page_index < 0 || new_page_index >= pages.size(): return false
	var new_page: Page = pages.get(new_page_index)
	if !new_page: return false
	__transfer_player_state(active_page, new_page)
	active_page_index = new_page_index
	active_page = new_page
	__refresh_page_positions()
	active_page.get_player_character().on_page_flip()
	return true

func __transfer_player_state(from_page: Page, to_page: Page) -> void:
	var page_player_state := from_page.get_player_state()
	to_page.set_player_state(page_player_state)

func __all_pages() -> Array[Page]:
	var result: Array[Page] = []
	result.append_array(__all_page3ds().map(func(page3d): return page3d.page))
	return result

func index_of_page(page: Page) -> int:
	return __all_pages().find(page)
	
func get_current_page_index() -> int:
	var pages := __all_pages()
	var current_page_index := pages.find(active_page)
	return current_page_index

func __all_page3ds() -> Array[Node3D]:
	var result: Array[Node3D] = []
	result.append_array($Pages.get_children().filter(func(child): return child is Page3D))
	return result

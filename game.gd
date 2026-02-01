extends Node3D

var active_page_index: int = 0
var active_page: Page:
	set(value):
		if value != active_page:
			active_page_changing.emit(value)
			active_page = value
			active_page_changed.emit(value)
signal active_page_changing(page: Page)
signal active_page_changed(page: Page)

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

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Page forward"):
		__flip_page_by(1)
	elif Input.is_action_just_pressed("Page backward"):
		__flip_page_by(-1)
	
	if Input.is_key_pressed(Key.KEY_R):
		get_tree().change_scene_to_file("res://game.tscn")
	
	var player_pos_2d := active_page.get_player_state().position
	var player_pos_3d := __pos2d_to_pos3d(player_pos_2d)
	$PlayerSprite.position.x = player_pos_3d.x
	$PlayerSprite.position.y = player_pos_3d.y

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
		var target_anim: TargetAnimation
		if page3d.has_meta("target_anim"):
			target_anim = page3d.get_meta("target_anim")
		else:
			target_anim = TargetAnimation.new()
			target_anim.updated.connect(
				func(value: float):
					page3d.position.z = value
			)
			add_child(target_anim)
			page3d.set_meta("target_anim", target_anim)
		target_anim.target = page_z

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
	return true

func __transfer_player_state(from_page: Page, to_page: Page) -> void:
	var page_player_state := from_page.get_player_state()
	to_page.set_player_state(page_player_state)

func __all_pages() -> Array[Page]:
	var result: Array[Page] = []
	result.append_array(__all_page3ds().map(func(page3d): return page3d.page))
	return result

func __all_page3ds() -> Array[Node3D]:
	var result: Array[Node3D] = []
	result.append_array($Pages.get_children())
	return result

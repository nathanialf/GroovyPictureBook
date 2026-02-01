@tool

class_name Page
extends Node2D

@export var page_color: Color = Color.GREEN
@export var page_background: Texture2D:
	set(value): __page_background.page_texture = value
	get(): return __page_background.page_texture

var __player_character: CharacterBody2D
var __page_background := PageBackground.new()
var __hole_test_body := AnimatableBody2D.new()

var is_active_page := false:
	set(value):
		if value != is_active_page:
			is_active_page = value
			is_active_page_changed.emit(value)
signal is_active_page_changed(value: bool)
var page_index := -1

func _init() -> void:
	if !Engine.is_editor_hint():
		__player_character = load("res://player_character.tscn").instantiate()
		add_child(__player_character)
		__player_character.position = Vector2(1920/2.0, 1080/2.0)
	
	add_child(__page_background)
	
	# copy player collision to hole tester
	var player_collision: CollisionShape2D = __player_character\
		.get_node("CollisionShape2D")
	__hole_test_body.add_child(player_collision.duplicate())
	__hole_test_body.set_collision_layer_value(1, false)
	__hole_test_body.set_collision_layer_value(2, true)
	add_child(__hole_test_body)

func _process(delta: float) -> void:
	__hole_test_body.position = $"../../../../".active_page.get_player_position()

func test_is_near_hole() -> bool:
	for hole in get_all_holes():
		if hole.overlaps_body(__hole_test_body):
			return true
	return false

func get_player_position() -> Vector2:
	return __player_character.position

func get_player_state() -> PagePlayerState:
	var pps := PagePlayerState.new()
	pps.position = __player_character.position
	pps.velocity = __player_character.get_real_velocity()
	return pps

func set_player_state(player_state: PagePlayerState) -> void:
	__player_character.position = player_state.position
	__player_character.velocity = player_state.velocity

func get_player_character() -> CharacterBody2D:
	return __player_character

func get_all_holes() -> Array[PageHole]:
	var result: Array[PageHole] = []
	result.append_array(get_children().filter(func(child): return child is PageHole))
	return result

class PagePlayerState:
	extends RefCounted

	var position: Vector2
	var velocity: Vector2

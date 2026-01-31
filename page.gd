class_name Page
extends Node2D

@export var page_color: Color = Color.GREEN

var __player_character: CharacterBody2D = load("res://player_character.tscn").instantiate()

var is_active_page := false:
	set(value):
		if value != is_active_page:
			is_active_page = value
			is_active_page_changed.emit(value)
signal is_active_page_changed(value: bool)
var page_index := -1

func _init() -> void:
	add_child(__player_character)
	__player_character.position = Vector2(1920/2.0, 0)

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

class PagePlayerState:
	extends RefCounted

	var position: Vector2
	var velocity: Vector2

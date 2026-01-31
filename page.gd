class_name Page
extends Node2D

var is_active_page := true:
	set(value):
		if value != is_active_page:
			is_active_page = value
			is_active_page_changed.emit(value)
signal is_active_page_changed(value: bool)

func get_player_state() -> PagePlayerState:
	var pps := PagePlayerState.new()
	pps.position = $CharacterBody2D.position
	pps.velocity = $CharacterBody2D.get_real_velocity()
	return pps

func set_player_state(player_state: PagePlayerState) -> void:
	$CharacterBody2D.position = player_state.position
	$CharacterBody2D.velocity = player_state.velocity

class PagePlayerState:
	extends RefCounted

	var position: Vector2
	var velocity: Vector2

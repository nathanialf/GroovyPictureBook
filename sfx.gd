class_name SFX
extends Node3D

static var PICKUP: AudioStream = preload("res://sfx/groovy picture book sfx pickup.mp3")
static var RESET: AudioStream = preload("res://sfx/groovy picture book sfx reset.mp3")
static var WIN: AudioStream = preload("res://sfx/groovy picture book sfx win.mp3")

signal sfx_placement_requested(node_to_place: Node3D, position_2d: Vector2)

func play(sfx: AudioStream) -> void:
	var player := AudioStreamPlayer.new()
	add_child(player)
	player.stream = sfx
	player.volume_db = -6
	player.play()
	await player.finished
	player.queue_free()

func play_at_position_2d(sfx: AudioStream, position_2d: Vector2) -> void:
	if !sfx_placement_requested.has_connections():
		push_error("SFX host needs to connect to sfx_placement_requested")
	var player := AudioStreamPlayer3D.new()
	sfx_placement_requested.emit(player, position_2d)
	player.stream = sfx
	player.volume_db = -6
	player.play()
	await player.finished
	player.queue_free()

func play_at_position_3d(sfx: AudioStream, position_3d: Vector3) -> void:
	var player := AudioStreamPlayer3D.new()
	# this doesn't work and idk why
	add_child(player)
	player.global_position = position_3d
	player.stream = sfx
	player.volume_db = -6
	player.play()
	await player.finished
	player.queue_free()

static func get_host(node: Node) -> SFX:
	var sfx = node.get("sfx_host")
	if sfx: return sfx
	if !node.get_parent():
		push_error("Couldn't find SFX host")
		return null
	return get_host(node.get_parent())

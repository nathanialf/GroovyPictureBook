@tool

class_name PageBackground
extends Node2D

@export var page_texture: Texture2D:
	set(value):
		page_texture = value
		__update_material_texture()

var __polygon := Polygon2D.new()
var __page_material := ShaderMaterial.new()
var __hole_mask_viewport := SubViewport.new()
var __hole_mask_drawer := _MaskDrawer.new()

func _init() -> void:
	# set up background polygon
	
	var rect := PackedVector2Array()
	rect.append(Vector2(0, 0))
	rect.append(Vector2(1920, 0))
	rect.append(Vector2(1920, 1080))
	rect.append(Vector2(0, 1080))
	__polygon.polygon = rect
	__polygon.texture_scale = Vector2(0.5, 0.5)
	__polygon.material = __page_material
	__page_material.shader = load("res://page_shader.gdshader")
	__polygon.texture = page_texture
	add_child(__polygon)
	
	# set up hole alpha mask
	
	__hole_mask_viewport.disable_3d = true
	__hole_mask_viewport.size = Vector2i(1920, 1080)
	__hole_mask_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	__hole_mask_viewport.transparent_bg = true
	__hole_mask_viewport.add_child(__hole_mask_drawer)
	__hole_mask_drawer.page_background = self
	add_child(__hole_mask_viewport)

func _ready() -> void:
	__update_material_texture()
	__page_material.set_shader_parameter("mask_tex", __hole_mask_viewport.get_texture())

func _process(delta: float) -> void:
	__hole_mask_drawer.queue_redraw()

func __update_material_texture() -> void:
	__page_material.set_shader_parameter("page_tex", page_texture)
	__polygon.texture = page_texture
	
	var tex_size := page_texture.get_size()
	var uv_w := 1920 * (tex_size.x / 1920) * 2
	var uv_h := 1080 * (tex_size.y / 1080) * 2
	var uv := PackedVector2Array()
	uv.append(Vector2(0, 0))
	uv.append(Vector2(uv_w, 0))
	uv.append(Vector2(uv_w, uv_h))
	uv.append(Vector2(0, uv_h))
	__polygon.uv = uv

func get_page() -> Page:
	return get_parent()

class _MaskDrawer:
	extends Node2D

	var page_background: PageBackground
	const MASK_COLOR := Color.WHITE
	const HOLE_COLOR := Color.BLACK

	func _draw() -> void:
		if !page_background: return

		draw_rect(Rect2(Vector2.ZERO, Vector2(1920.0, 1080.0)), MASK_COLOR, true)

		var page := page_background.get_page()
		if !page: return

		for hole in page.get_all_holes():
			__draw_hole(hole)

	func __draw_hole(hole: PageHole) -> void:
		for child in hole.get_children():
			if child is CollisionShape2D:
				__draw_collision_shape(child)

	func __draw_collision_shape(collision: CollisionShape2D) -> void:
		if !collision.shape: return

		var local_xform := get_global_transform().affine_inverse() * collision.global_transform
		draw_set_transform_matrix(local_xform)

		var shape := collision.shape
		if shape is CircleShape2D:
			draw_circle(Vector2.ZERO, shape.radius, HOLE_COLOR)
		elif shape is RectangleShape2D:
			draw_rect(Rect2(-shape.size * 0.5, shape.size), HOLE_COLOR, true)
		elif shape is CapsuleShape2D:
			var radius: float = shape.radius
			var rect_height := maxf(shape.height - (radius * 2.0), 0.0)
			var half_rect := rect_height * 0.5
			draw_rect(Rect2(Vector2(-radius, -half_rect), Vector2(radius * 2.0, rect_height)), HOLE_COLOR, true)
			draw_circle(Vector2(0, -half_rect), radius, HOLE_COLOR)
			draw_circle(Vector2(0, half_rect), radius, HOLE_COLOR)
		elif shape is ConvexPolygonShape2D:
			draw_polygon(shape.points, PackedColorArray([HOLE_COLOR]))
		else:
			draw_rect(shape.get_rect(), HOLE_COLOR, true)

		draw_set_transform_matrix(Transform2D.IDENTITY)

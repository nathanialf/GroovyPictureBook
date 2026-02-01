extends SpotLight3D

var origin_node: Node3D
var page: Page

var __outline_viewport := SubViewport.new()
var __outline_drawer := _OutlineDrawer.new()
@onready var __original_energy := light_energy

const TEXTURE_SIZE := Vector2i(1920, 1920)
const Y_OFFSET := (TEXTURE_SIZE.y - 1080) / 2.0

func _ready() -> void:
	__outline_viewport.disable_3d = true
	__outline_viewport.size = TEXTURE_SIZE
	__outline_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	__outline_viewport.transparent_bg = true
	__outline_viewport.add_child(__outline_drawer)
	__outline_drawer.page = page
	add_child(__outline_viewport)
	
	light_energy = 0.0
	await get_tree().process_frame
	await get_tree().process_frame
	var outline_image := __outline_viewport.get_texture().get_image()
	light_projector = ImageTexture.create_from_image(outline_image)

func _process(delta: float) -> void:
	global_transform = origin_node.global_transform
	__outline_drawer.queue_redraw()

func start_casting() -> void:
	create_tween().tween_property(self, "light_energy", __original_energy, 0.5)

func stop_casting() -> void:
	create_tween().tween_property(self, "light_energy", 0.0, 0.5)

class _OutlineDrawer:
	extends Node2D

	var page: Page 
	const OUTLINE_WIDTH := 10.0
	
	func _draw() -> void:
		if !page: return

		for wall in page.get_all_walls():
			__draw_node_collision_shapes(wall)

		for hole in page.get_all_holes():
			__draw_node_collision_shapes(hole)

#		draw_rect(Rect2(Vector2.ZERO, Vector2(TEXTURE_SIZE.x, TEXTURE_SIZE.y)), page.page_color, false, OUTLINE_WIDTH, true)
	
	func __draw_node_collision_shapes(node: Node2D) -> void:
		var page_color := page.page_color

		var local_xform := get_global_transform().affine_inverse() * node.global_transform

		var shape_scale := local_xform.get_scale()

		# remove scale from transform, otherwise our outlines will be scaled too
		var xform_no_scale := Transform2D(
			local_xform.x.normalized(),
			local_xform.y.normalized(),
			local_xform.origin + Vector2(0, Y_OFFSET)
		)

		draw_set_transform_matrix(xform_no_scale)

		for child in node.get_children():
			if child is CollisionShape2D:
				var shape: Shape2D = child.shape
				if !shape: continue

				var child_xform := Transform2D(child.rotation, child.position * shape_scale)
				draw_set_transform_matrix(xform_no_scale * child_xform)

				if shape is CircleShape2D:
					draw_arc(Vector2.ZERO, shape.radius * shape_scale.x, 0, TAU, 32, page_color, OUTLINE_WIDTH, true)
				elif shape is RectangleShape2D:
					var scaled_size: Vector2 = shape.size * shape_scale
					draw_rect(Rect2(-scaled_size * 0.5, scaled_size), page_color, false, OUTLINE_WIDTH, true)
				elif shape is CapsuleShape2D:
					var radius: float = shape.radius * shape_scale.x
					var half_height: float = (shape.height * shape_scale.y) * 0.5
					var cap_offset: float = half_height - radius
					draw_line(Vector2(-radius, -cap_offset), Vector2(-radius, cap_offset), page_color, OUTLINE_WIDTH)
					draw_line(Vector2(radius, -cap_offset), Vector2(radius, cap_offset), page_color, OUTLINE_WIDTH)
					draw_arc(Vector2(0, -cap_offset), radius, PI, TAU, 32, page_color, OUTLINE_WIDTH, true)
					draw_arc(Vector2(0, cap_offset), radius, 0, PI, 32, page_color, OUTLINE_WIDTH, true)
				elif shape is ConvexPolygonShape2D:
					push_error("convex polygons not supported in outlines yet")

				draw_set_transform_matrix(xform_no_scale)
			elif child is CollisionPolygon2D:
				push_error("collision polygons not supported in outlines yet")

		draw_set_transform_matrix(Transform2D.IDENTITY)

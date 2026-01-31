class_name TargetAnimation
extends Node

@export var config: TargetAnimationConfig = TargetAnimationConfig.new()

signal updated(value: float)

@export var velocity: float = 0.0
@export var current: float = 0.0
@export var target: float = 0.0
@export var snap_to_next_target: bool = true

var __calc_current := current
var __last_calc_current := current
var __calc_current_wrap := 0
var __last_target := target

func snap_to(value: float, update_target: bool = true) -> void:
	current = value
	__calc_current = value
	__last_calc_current = value
	velocity = 0.0
	if update_target: target = value

func _ready() -> void:
	snap_to(current)

func _process(delta: float) -> void:
	if config.physics_process:
		var last := current
		var wrap_offset := 0.0
		if config.modulo != 0.0:
			wrap_offset = config.modulo * __calc_current_wrap
		current = lerpf(__last_calc_current + wrap_offset, __calc_current,
			Engine.get_physics_interpolation_fraction())
		if last != current:
			updated.emit(current)
	elif !config.manual_process:
		var last := current
		__calculate(delta)
		current = __calc_current
		if last != current:
			updated.emit(current)

func _physics_process(delta: float) -> void:
	if config.physics_process && !config.manual_process:
		__calculate(delta)

func update(delta: float) -> void:
	if !config.manual_process:
		push_error("Manually updating a decay animation that is not set to manual update mode")
	var last := current
	__calculate(delta)
	current = __calc_current
	if last != current:
		updated.emit(current)

func __calculate(delta: float) -> void:
	__last_calc_current = __calc_current
	if snap_to_next_target:
		__calc_current = target
		snap_to_next_target = false
	else:
		if config.modulo != 0:
			__calc_current_wrap = __get_wrap_direction(target, __last_target)
			__calc_current += config.modulo * __calc_current_wrap
		var displacement := target - __calc_current
		var force := config.spring_constant * displacement + config.damping_constant * velocity
		velocity -= force * delta
		if config.max_velocity != 0:
			velocity = clampf(velocity, -config.max_velocity, config.max_velocity)
		__calc_current -= velocity * delta
	__last_target = target

func __get_wrap_direction(new_value: float, prev_value: float) -> int:
	if absf(new_value - prev_value) > absf((new_value + config.modulo) - prev_value):
		return -1
	if absf(new_value - prev_value) > absf(new_value - (prev_value + config.modulo)):
		return 1
	return 0

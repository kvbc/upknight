extends CharacterBody2D
class_name Player

const SPEED = 2000
const GRAVITY = 1000
const JUMP_POWER = 6000
const DASH_POWER = 6000
const HOOK_POWER = 3000

var can_jump = false
var dashing = false
var hook_pos = Vector2.ZERO
var jump_velocity = Vector2.ZERO
var dash_velocity = Vector2.ZERO
var hook_velocity = Vector2.ZERO

func _ready ():
	pass
	
func _draw ():
	if hook_pos != Vector2.ZERO:
		draw_line(Vector2.ZERO, to_local(hook_pos), Color.WHITE, 5.0)
	
func _process (delta):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var laser_data = get_world_2d().direct_space_state.intersect_ray(PhysicsRayQueryParameters2D.create(
			global_position,
			global_position + global_position.direction_to(get_global_mouse_position()) * 2000,
			0xFFFFFFFF,
			[get_rid()]
		))
		if laser_data.is_empty():
			hook_pos = Vector2.ZERO
		else:
			hook_pos = laser_data.position
			hook_velocity = global_position.direction_to(get_global_mouse_position()) * HOOK_POWER
	else:
		hook_pos = Vector2.ZERO
		hook_velocity = Vector2.ZERO
	if hook_pos == Vector2.ZERO:
		hook_velocity = hook_velocity.lerp(Vector2.ZERO, delta * 10)
	
	if Input.is_key_pressed(KEY_W):
		if can_jump:
			if $can_jump.has_overlapping_bodies():
				jump_velocity = Vector2(0, -JUMP_POWER)
				can_jump = false
				get_tree().create_timer(0.25).timeout.connect(func ():
					can_jump = true	
				)
	
	if not is_on_floor():
		jump_velocity = jump_velocity.lerp(Vector2.ZERO, delta * 10)
	
	if Input.is_key_pressed(KEY_SHIFT):
		if not dashing:
			dashing = true
			dash_velocity = DASH_POWER * global_position.direction_to(get_global_mouse_position())
	dash_velocity = dash_velocity.lerp(Vector2.ZERO, delta * 10)
	
	if Input.is_key_pressed(KEY_SPACE):
		Engine.time_scale = 0.5
	else:
		Engine.time_scale = 1.0
	
	if is_on_floor():
		dashing = false
		can_jump = true
	
	var move = Vector2.ZERO
	if Input.is_key_pressed(KEY_A):
		move += Vector2.LEFT
		$Sprite2D.flip_h = true
	if Input.is_key_pressed(KEY_S):
		move += Vector2.DOWN
	if Input.is_key_pressed(KEY_D):
		move += Vector2.RIGHT
		$Sprite2D.flip_h = false
		
	velocity = move * SPEED
	velocity += Vector2(0, GRAVITY)
	velocity += jump_velocity
	velocity += dash_velocity
	velocity += hook_velocity
	move_and_slide()
	
#	var col = get_last_slide_collision()
#	if col:
#		if col.get_collider() is Furniture:
#			if col.get_normal().is_equal_approx(Vector2.DOWN):
#				print("dead")
				# print(col.get_normal())
	
	queue_redraw()

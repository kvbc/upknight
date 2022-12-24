extends CharacterBody2D
class_name Furniture

var push_to_v = Vector2.ZERO
var fallen = false

func push_to (dir):
	push_to_v = dir

func _process (delta):
	var move_by = Vector2(0, Global.furniture_gravity)
	move_by += push_to_v * 5000
	push_to_v = push_to_v.lerp(Vector2.ZERO, delta * 10)
	var col = move_and_collide(move_by * delta)
	if col:
		if not fallen:
			$AudioStreamPlayer2D.play()
			fallen = true
		if col.get_collider() is Player:
			if col.get_normal().y < -0.9:
				Signals.dead.emit()				
				Engine.time_scale = 0.5

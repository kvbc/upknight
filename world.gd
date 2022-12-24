extends Node2D

var top_y = -2
var old_camera_tile_y = null
var all_furniture = ["chair", "couch", "fridge"]
var rng = RandomNumberGenerator.new()
var spawn_delay = 1.0
var camera_speed = 50
var score = 0

func set_wall (x, id):
	$tilemap.set_cell(0, Vector2(x,top_y), id, Vector2.ZERO)

func add_wall ():
	set_wall(0, 0)
	for i in range(1, 7):
		set_wall(i, 1)
	set_wall(7, 0)
	top_y -= 1

func spawn_loop ():
	while true:
		await get_tree().create_timer(spawn_delay).timeout
		var furniture = all_furniture[rng.randi_range(0, all_furniture.size() - 1)]
		var randx = rng.randi_range(1, 6)
		var obj = load("res://furniture/" + furniture + ".tscn").instantiate()
		obj.position = $tilemap.map_to_local(Vector2(randx, top_y - 10))
		$furniture.add_child(obj)

func _ready ():
	for i in 10:
		add_wall()
	# bg.position.y = $tilemap.map_to_local(Vector2(0,top_y/2)).y
	spawn_loop()
	
	Signals.restart.connect(func ():
		for c in $furniture.get_children():
			c.queue_free()
		$player.position = Vector2(500, -215)
		top_y = -2
		old_camera_tile_y = null
		score = 0
		Signals.score_updated.emit(0)
		Engine.time_scale = 1.0
	)
	$AudioStreamPlayer.play()

func _process (delta):
	# $camera.position.x = $player.position.x
	# $camera.position.y -= camera_speed * delta
	# $camera.position.y = $player.position.y - 350
	$camera.position = $camera.position.lerp($player.position - Vector2(0,350), delta * 10)
	
	var camera_tile_y = $tilemap.local_to_map($camera.position).y
	if old_camera_tile_y == null:
		old_camera_tile_y = camera_tile_y
	elif old_camera_tile_y != camera_tile_y:
		add_wall()
		var diff = abs(camera_tile_y) - abs(old_camera_tile_y)
		old_camera_tile_y = camera_tile_y
		score += diff
		Signals.score_updated.emit(score)
		var scores = [5, 10, 25, 50, 100]
		var mults = [1.25, 1.5, 1.75, 2, 2.25]
		if score in scores:
			var mult = mults[scores.find(score)]
			# camera_speed = 50 * mult
			spawn_delay = 0.5 * mult
			Global.furniture_gravity = 1000 * mult

extends Area2D

var start_pos : Vector2
var target_pos : Vector2

var XSPEED = 0
var YSPEED = 0

var XDIR = -1
var YDIR = 0

func _ready():
	XSPEED = 100
	start_pos = global_position
	target_pos = Vector2(start_pos.x - 500, start_pos.y)

func _process(delta):
	$AnimatedSprite.play("default")
	position.x += XDIR * XSPEED * delta * Main.no_pause_state * Main.TEST_SPEED
	position.y += YDIR * YSPEED * delta * Main.no_pause_state * Main.TEST_SPEED
	
	flip_x_dir(start_pos, target_pos)
	
	if Main.no_pause_state == 0:
		self.freeze()
	else:
		self.unfreeze()
		
func _on_body_entered(body):
	if body.is_in_group("Player"):
		body.die()


func freeze():
	$AnimatedSprite.pause()

func unfreeze():
	$AnimatedSprite.play("default")
	
func flip_x_dir(start, target):
	if global_position.x < target.x:
		XDIR = 1
	elif global_position.x > start.x:
		XDIR = -1

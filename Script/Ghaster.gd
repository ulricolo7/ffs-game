extends Enemy

func _ready():
	start_pos = global_position

func _process(delta):
	$AnimatedSprite.play("default")
	position.x += XDIR * XSPEED * delta * Main.no_pause_state * Main.TEST_SPEED
	position.y += YDIR * YSPEED * delta * Main.no_pause_state * Main.TEST_SPEED
	
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

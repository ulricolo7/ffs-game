extends Enemy

func _ready():
	start_pos = global_position

func _process(delta):
	if position.x < -100:
		queue_free()
		
	position.x += XDIR * XSPEED * delta * Main.no_pause_state
	position.y += YDIR * YSPEED * delta * Main.no_pause_state
		
func _on_body_entered(body):
	if body.is_in_group("Player"):
		body.die()


extends Enemy


func _ready():
	XSPEED = 100
	YSPEED = 50
	YDIR = 1
	start_pos = global_position
	target_pos = Vector2(position.x, position.y + 1000)

func _process(delta):
	if position.y > target_pos.y:
		YDIR = -1
	elif position.y < start_pos.y:
		YDIR = 1
	
	position.x += XDIR * XSPEED * delta * Main.no_pause_state
	position.y += YDIR * YSPEED * delta * Main.no_pause_state
		
func _on_body_entered(body):
	if body.is_in_group("Player"):
		body.die()

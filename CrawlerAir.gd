extends Enemy


func _ready():
	XSPEED = 100
	YSPEED = 30
	YDIR = 1
	start_pos = global_position
	target_pos = Vector2(position.x, position.y + 300)

func _process(delta):
	if position.y > target_pos.y:
		YDIR = -1
	elif position.y < start_pos.y:
		YDIR = 1
	
	position.x += XDIR * XSPEED * delta
	position.y += YDIR * YSPEED * delta
	
	if position.x < -100:
		queue_free()
		
func _on_body_entered(body):
	if body.is_in_group("Player"):
		body.die()

extends Enemy


func _ready():
	XSPEED = 100
	start_pos = global_position
	target_pos = Vector2.ZERO

func _process(delta):
	
	position.x += XDIR * XSPEED * delta
	position.y += YDIR * YSPEED * delta
	
	if position.x < -100:
		queue_free()
		
func _on_body_entered(body):
	if body.is_in_group("Player"):
		body.die()
		

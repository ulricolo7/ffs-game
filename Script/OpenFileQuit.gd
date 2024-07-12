extends TextureButton

signal close_level_select

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Main.editor_paused:
		self.disabled = true
	else:
		self.disabled = false

func _on_pressed():
	play_click_sfx()
	Main.level_switching = false
	Main.editor_paused = false
	Main.player_input_disabled = false
	emit_signal("close_level_select")

func play_click_sfx():
	$ClickSFX.play()

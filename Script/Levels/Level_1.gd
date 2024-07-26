var level_path = "res://Script/Levels/Level_1.gd"
var last_updated = "2024-07-26T23:19:01"
var is_completed = false
var is_saved = true
var bgm = "res://Assets/BGM/Action.mp3"

var last_enemy_x = 10126

var enemy_data = {
	0: {"position": Vector2(892, 183), "type": "gh"},
	1: {"position": Vector2(1248, 710), "type": "cg"},
	2: {"position": Vector2(1649, 535), "type": "gh"},
	3: {"position": Vector2(2043, 192), "type": "fl"},
	4: {"position": Vector2(2188, 256), "type": "fl"},
	5: {"position": Vector2(2744, 313), "type": "gh"},
	6: {"position": Vector2(3205, 622), "type": "gh"},
	7: {"position": Vector2(3200, 710), "type": "cg"},
	8: {"position": Vector2(3661, 249), "type": "ca"},
	9: {"position": Vector2(3938, 459), "type": "gh"},
	10: {"position": Vector2(3939, 307), "type": "gh"},
	11: {"position": Vector2(4540, 264), "type": "fl"},
	12: {"position": Vector2(4821, 515), "type": "fl"},
	13: {"position": Vector2(6098, 710), "type": "cg"},
	14: {"position": Vector2(5413, 188), "type": "gh"},
	15: {"position": Vector2(6352, 369), "type": "ca"},
	16: {"position": Vector2(6822, 160), "type": "gh"},
	17: {"position": Vector2(6834, 650), "type": "gh"},
	18: {"position": Vector2(6971, 235), "type": "gh"},
	19: {"position": Vector2(6965, 559), "type": "gh"},
	20: {"position": Vector2(7259, 251), "type": "gh"},
	21: {"position": Vector2(7400, 160), "type": "gh"},
	22: {"position": Vector2(7266, 566), "type": "gh"},
	23: {"position": Vector2(7400, 670), "type": "gh"},
	24: {"position": Vector2(8632, 710), "type": "cg"},
	25: {"position": Vector2(8371, 710), "type": "cg"},
	26: {"position": Vector2(8225, 170), "type": "fl"},
	27: {"position": Vector2(9174, 337), "type": "fl"},
	28: {"position": Vector2(9373, 641), "type": "fl"},
	29: {"position": Vector2(9730, 160), "type": "gh"},
	30: {"position": Vector2(10126, 377), "type": "gh"},
	31: {"position": Vector2(10054, 710), "type": "cg"},
	32: {"position": Vector2(1016, 260), "type": "gh"},
	33: {"position": Vector2(767.7455, 231.4286), "type": "gh"},
	34: {"position": Vector2(651.684, 229.8701), "type": "gh"},
}


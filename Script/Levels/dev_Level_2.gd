var level_path = "res://Script/Levels/Level_1.gd"
var last_updated = "2024-07-26T16:16:06"
var is_completed = true
var is_saved = true
var bgm = "res://Assets/BGM/Action.mp3"

var last_enemy_x = 30561.259765625

var enemy_data = {
	0: {"position": Vector2(951, 267), "type": "gh"},
	1: {"position": Vector2(1585, 591), "type": "gh"},
	2: {"position": Vector2(2429, 263), "type": "fl"},
	3: {"position": Vector2(3596, 710), "type": "cg"},
	4: {"position": Vector2(3221, 710), "type": "cg"},
	5: {"position": Vector2(4698, 149), "type": "ca"},
	6: {"position": Vector2(4462, 387), "type": "fl"},
	7: {"position": Vector2(5034, 528), "type": "gh"},
	8: {"position": Vector2(6044, 599), "type": "gh"},
	9: {"position": Vector2(6320, 199), "type": "gh"},
	10: {"position": Vector2(7143, 446), "type": "fl"},
	11: {"position": Vector2(7010, 164), "type": "ca"},
	12: {"position": Vector2(7544, 710), "type": "cg"},
	13: {"position": Vector2(8213, 223), "type": "gh"},
	14: {"position": Vector2(7770, 244), "type": "gh"},
	15: {"position": Vector2(8426, 483), "type": "fl"},
	16: {"position": Vector2(9293, 553), "type": "fl"},
	17: {"position": Vector2(9458, 191), "type": "fl"},
	18: {"position": Vector2(8882, 271), "type": "fl"},
	19: {"position": Vector2(3712, 200), "type": "fl"},
	20: {"position": Vector2(10526, 710), "type": "cg"},
	21: {"position": Vector2(10256, 203), "type": "gh"},
	22: {"position": Vector2(10843, 471), "type": "gh"},
	23: {"position": Vector2(10771, 602), "type": "gh"},
	24: {"position": Vector2(11731.67, 289.1718), "type": "fl"},
	25: {"position": Vector2(12113.17, 710), "type": "cg"},
	26: {"position": Vector2(12142.13, 440.2472), "type": "gh"},
	27: {"position": Vector2(13865.82, 224.796), "type": "fl"},
	28: {"position": Vector2(14052.3, 474.5117), "type": "fl"},
	29: {"position": Vector2(13384.21, 184.8208), "type": "fl"},
	30: {"position": Vector2(14505.51, 130.8282), "type": "ca"},
	31: {"position": Vector2(14929.36, 463.0902), "type": "gh"},
	32: {"position": Vector2(15169.36, 235.1792), "type": "gh"},
	33: {"position": Vector2(15327.17, 710), "type": "cg"},
	34: {"position": Vector2(14460.77, 710), "type": "cg"},
	35: {"position": Vector2(15019.33, 710), "type": "cg"},
	36: {"position": Vector2(15734.61, 489.5674), "type": "gh"},
	37: {"position": Vector2(16194.02, 710), "type": "cg"},
	38: {"position": Vector2(16516.73, 120), "type": "ca"},
	39: {"position": Vector2(16503.16, 501.508), "type": "fl"},
	40: {"position": Vector2(16133.55, 164.0544), "type": "fl"},
	41: {"position": Vector2(16979, 150), "type": "ca"},
	42: {"position": Vector2(17217.59, 420.5191), "type": "gh"},
	43: {"position": Vector2(18142.38, 192.6081), "type": "ca"},
	44: {"position": Vector2(18453.85, 420), "type": "ca"},
	45: {"position": Vector2(17962.14, 218.5661), "type": "fl"},
	46: {"position": Vector2(17858.84, 710), "type": "cg"},
	47: {"position": Vector2(18609.47, 710), "type": "cg"},
	48: {"position": Vector2(19030.61, 382.6205), "type": "gh"},
	49: {"position": Vector2(19466.79, 641.1619), "type": "gh"},
	50: {"position": Vector2(19315.6, 187.4165), "type": "gh"},
	51: {"position": Vector2(20560.68, 538.8875), "type": "gh"},
	52: {"position": Vector2(20790.64, 198.8381), "type": "gh"},
	53: {"position": Vector2(20764.17, 710), "type": "cg"},
	54: {"position": Vector2(21462.05, 206.6254), "type": "gh"},
	55: {"position": Vector2(21974.08, 637.0086), "type": "gh"},
	56: {"position": Vector2(22444.15, 215.4512), "type": "gh"},
	57: {"position": Vector2(21996.68, 172.8801), "type": "fl"},
	58: {"position": Vector2(22649.2, 454.7837), "type": "fl"},
	59: {"position": Vector2(21551.8, 545.6365), "type": "fl"},
	60: {"position": Vector2(23555, 710), "type": "cg"},
	61: {"position": Vector2(23037.45, 710), "type": "cg"},
	62: {"position": Vector2(23103.89, 167.6885), "type": "gh"},
	63: {"position": Vector2(23394.6, 322.9172), "type": "gh"},
	64: {"position": Vector2(24883.16, 148.4796), "type": "ca"},
	65: {"position": Vector2(25329.19, 213.8937), "type": "ca"},
	66: {"position": Vector2(25062.36, 710), "type": "cg"},
	67: {"position": Vector2(25251.32, 434.5364), "type": "fl"},
	68: {"position": Vector2(25682.63, 244.5241), "type": "gh"},
	69: {"position": Vector2(26073, 420), "type": "gh"},
	70: {"position": Vector2(25948.41, 710), "type": "cg"},
	71: {"position": Vector2(26661.16, 710), "type": "cg"},
	72: {"position": Vector2(26664.27, 160), "type": "gh"},
	73: {"position": Vector2(26961.72, 401.8294), "type": "gh"},
	74: {"position": Vector2(27607.75, 123.5599), "type": "ca"},
	75: {"position": Vector2(27740.71, 448.0346), "type": "fl"},
	76: {"position": Vector2(28164.84, 283.4611), "type": "fl"},
	77: {"position": Vector2(28628.8, 434.5364), "type": "fl"},
	78: {"position": Vector2(28899.78, 147.4413), "type": "ca"},
	79: {"position": Vector2(29233.84, 710), "type": "cg"},
	80: {"position": Vector2(29664.16, 338.4919), "type": "fl"},
	81: {"position": Vector2(29940.85, 485.4141), "type": "gh"},
	82: {"position": Vector2(30554.51, 649.4684), "type": "gh"},
	83: {"position": Vector2(30561.26, 160), "type": "gh"},
	84: {"position": Vector2(11127.3, 160), "type": "gh"},
	85: {"position": Vector2(11217.11, 299.0358), "type": "gh"},
	86: {"position": Vector2(11737.65, 710), "type": "cg"},
	87: {"position": Vector2(12529.82, 255.9456), "type": "fl"},
	88: {"position": Vector2(12851.92, 323.9555), "type": "ca"},
	89: {"position": Vector2(13119.26, 178.0717), "type": "ca"},
	90: {"position": Vector2(19908.03, 249.1965), "type": "gh"},
	91: {"position": Vector2(20096.98, 527.466), "type": "gh"},
	92: {"position": Vector2(24096.17, 396.6378), "type": "fl"},
	93: {"position": Vector2(24458.44, 214.4128), "type": "ca"},
	94: {"position": Vector2(24291.22, 538.3683), "type": "gh"},
}




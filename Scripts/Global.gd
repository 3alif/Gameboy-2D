extends Node

var max_lives = 3
var lives = max_lives
var hud

func life_loss():
	lives -= 1
	hud.load_hearts()
	if lives == 0:
		get_tree().change_scene("res://Scenes/GameOver.tscn")

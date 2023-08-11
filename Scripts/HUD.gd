extends CanvasLayer

var coins = 0

func _ready():
	$Coins.text = String(coins)
	load_hearts()
	Global.hud = self


func _on_coin_collected():
	coins = coins + 1
	_ready()
	
	if coins == 15:
		get_tree().change_scene("res://Scenes/Win.tscn")

func load_hearts():
	$FullHeart.rect_size.x = Global.lives * 53
	$HurtHeart.rect_size.x = (Global.max_lives - Global.lives) * 53
	$HurtHeart.rect_position.x = $FullHeart.rect_position.x + $FullHeart.rect_size.x * $FullHeart.rect_scale.x

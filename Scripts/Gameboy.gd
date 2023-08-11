extends KinematicBody2D

enum States {AIR = 1, FLOOR, LADDER, WALL}
var state = States.AIR

var velocity = Vector2(0, 0)
var direction = 1
var last_jump_direction = 0
var on_ladder := false

const SPEED = 240
const RUN = 400
const JUMPFORCE = -1100
const GRAVITY = 40

const FIREBALL = preload("res://Scenes/Fireball.tscn")


func _physics_process(delta):
	match state:
		States.AIR:
			if is_on_floor() and velocity.y == 0:
				last_jump_direction = 0
				state = States.FLOOR
				continue
			elif is_touching_wall():
				state = States.WALL
				continue
			elif just_climb():
				state = States.LADDER
				continue
			
			$Sprite.play("air")
			
			if Input.is_action_pressed("move_right"):
				velocity.x = lerp(velocity.x, SPEED, 0.1) if velocity.x < SPEED else lerp(velocity.x, SPEED, 0.03)
				$Sprite.flip_h = false
			
			elif Input.is_action_pressed("move_left"):
				velocity.x = lerp(velocity.x, -SPEED, 0.1) if velocity.x > -SPEED else lerp(velocity.x, -SPEED, 0.03)
				$Sprite.flip_h = true
			
			else:
				velocity.x = lerp(velocity.x, 0, 0.2)
			
			set_direction()
			move_and_fall(false)
			fire()
		
		States.FLOOR:
			if not is_on_floor():
				state = States.AIR
				continue
			elif just_climb():
				state = States.LADDER
				continue
			
			if Input.is_action_pressed("move_right"):
				
				if Input.is_action_pressed("run"):
					velocity.x = lerp(velocity.x, RUN, 0.1)
					$Sprite.set_speed_scale(1.65)
				else:
					velocity.x = lerp(velocity.x, SPEED, 0.1)
					$Sprite.set_speed_scale(1)
				
				$Sprite.play("walk")
				$Sprite.flip_h = false
			
			elif Input.is_action_pressed("move_left"):
				
				if Input.is_action_pressed("run"):
					velocity.x = lerp(velocity.x, -RUN, 0.1)
					$Sprite.set_speed_scale(1.65)
				else:
					velocity.x = lerp(velocity.x, -SPEED, 0.1)
					$Sprite.set_speed_scale(1)
				
				$Sprite.play("walk")
				$Sprite.flip_h = true
			
			else:
				$Sprite.play("idle")
				velocity.x = lerp(velocity.x, 0, 0.2)
	
			if Input.is_action_just_pressed("jump"):
				velocity.y = JUMPFORCE
				$JumpSound.play()
				state = States.AIR
			
			set_direction()
			move_and_fall(false)
			fire()
		
		States.WALL:
			if is_on_floor():
				last_jump_direction = 0
				state = States.FLOOR
				continue
			elif not is_touching_wall():
				state = States.AIR
				continue
			
			$Sprite.play("air")
			
			if direction != last_jump_direction and Input.is_action_pressed("jump") and ((Input.is_action_pressed("move_left") and direction == 1) or (Input.is_action_pressed("move_right") and direction == -1)):
				last_jump_direction = direction
				velocity.x = 500 * -direction
				velocity.y = JUMPFORCE * 0.7
				$JumpSound.play()
				state = States.AIR
				
			move_and_fall(true)
		
		States.LADDER:
			if not on_ladder:
				state = States.AIR
				continue
			elif is_on_floor() and Input.is_action_pressed("down") and velocity.y == 0:
				state = States.FLOOR
				Input.action_release("down")
				Input.action_release("up")
				continue
			elif Input.is_action_just_pressed("jump"):
				Input.action_release("down")
				Input.action_release("up")
				velocity.y = JUMPFORCE * 0.5
				state = States.AIR
				continue
			
			if Input.is_action_pressed("up") or Input.is_action_pressed("down") or Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
				$Sprite.play("climb")
			else:
				$Sprite.stop()
			
			if Input.is_action_pressed("up"):
				velocity.y = -SPEED * 0.8
			elif Input.is_action_pressed("down"):
				velocity.y = SPEED * 0.8
			else:
				velocity.y = lerp(velocity.y, 0, 0.3)
			
			if Input.is_action_pressed("move_left"):
				velocity.x = -SPEED/6
			elif Input.is_action_pressed("move_right"):
				velocity.x = SPEED/6
			else:
				velocity.x = lerp(velocity.x, 0, 0.3)
			
			velocity = move_and_slide(velocity, Vector2.UP)

func just_climb() -> bool:
	if on_ladder and (Input.is_action_pressed("up") or Input.is_action_pressed("down")):
		return true
	else:
		return false

func set_direction():
	direction = 1 if not $Sprite.flip_h else -1
	$Wallchecker.rotation_degrees = 90 * -direction

func is_touching_wall():
	return $Wallchecker.is_colliding() and not $Wallchecker.get_collider().is_in_group("1way")

func fire():
	if Input.is_action_just_pressed("fire") and not is_touching_wall():
		var f = FIREBALL.instance()
		
		f.direction = direction
		
		get_parent().add_child(f)
		f.position.x = position.x + (25 * direction)
		f.position.y = position.y

func move_and_fall(slowed : bool):
	velocity.y = velocity.y + GRAVITY
	
	if slowed:
		velocity.y = clamp(velocity.y, JUMPFORCE, 200)
	
	velocity = move_and_slide(velocity, Vector2.UP)

func _on_Fallzone_body_entered(body):
	Global.life_loss()
	if Global.lives > 0:
		get_tree().reload_current_scene()

func bounce():
	velocity.y = JUMPFORCE * 0.5

func hurt(var enemyposx):
	Global.life_loss()
	set_modulate(Color(1, 0.5, 0.5, 0.7))
	velocity.y = JUMPFORCE * 0.3
	
	if position.x < enemyposx:
		velocity.x = -700
	elif position.x > enemyposx:
		velocity.x = 700
	
	Input.action_release("move_left")
	Input.action_release("move_right")
	
	$Timer.start()

func _on_Timer_timeout():
	set_modulate(Color(1, 1, 1, 1))

func _on_Area2D_body_entered(body):
	on_ladder = true

func _on_Area2D_body_exited(body):
	on_ladder = false

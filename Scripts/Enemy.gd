extends KinematicBody2D

var speed = 50
var velocity = Vector2()
export var direction = -1
export var cliff_detection = true


func _ready():
	if direction == 1:
		$AnimatedSprite.flip_h = true
		
	$SurfaceChecker.position.x = $CollisionShape2D.shape.get_extents().x * direction
	$SurfaceChecker.enabled = cliff_detection
	
	if not cliff_detection:
		set_modulate(Color(1.2, 0.5, 1))


func _physics_process(delta):
	if is_on_wall() or not $SurfaceChecker.is_colliding() and cliff_detection and is_on_floor():
		direction *= -1
		$AnimatedSprite.flip_h = not $AnimatedSprite.flip_h
		$SurfaceChecker.position.x = $CollisionShape2D.shape.get_extents().x * direction
	
	velocity.y += 20
	velocity.x = speed * direction
	
	velocity = move_and_slide(velocity, Vector2.UP)


func _on_AttackingZone_body_entered(body):
	$AnimatedSprite.play("Squashed")
	speed = 0
	set_collision_layer_bit(4, false)
	set_collision_mask_bit(0, false)
	$AttackingZone.set_collision_layer_bit(4, false)
	$AttackingZone.set_collision_mask_bit(0, false)
	$AttackedBy.set_collision_layer_bit(4, false)
	$AttackedBy.set_collision_mask_bit(0, false)
	$Timer.start()
	body.bounce()
	$SquashSound.play()


func _on_AttackedBy_body_entered(body):
	if body.get_collision_layer() == 1:
		body.hurt(position.x)
	elif body.get_collision_layer() == 32:
		body.queue_free()
		queue_free()


func _on_Timer_timeout():
	queue_free()

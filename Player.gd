extends Area2D

signal hit

export var speed = 400 # How fast the player will move (pixels/sec).
var screen_size # Size of the game window.
var touch_from_position
var touch_current

func _ready():
	screen_size = get_viewport_rect().size
	hide()

func _input(event):
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		if event.pressed:
			if not touch_from_position:
				touch_from_position = event.position - position
			touch_current = event.position
		else:
			touch_from_position = null
			touch_current = null
	elif event is InputEventMouseMotion and touch_from_position:
		touch_current = event.position

func _process(delta):
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	if touch_current:
		velocity = touch_current - (touch_from_position + position)

	# checked before normalisation
	if velocity.length() < 0:
		pass
	elif abs(velocity.x) > abs(velocity.y):
		$AnimatedSprite.animation = "right"
		$AnimatedSprite.flip_v = false
		$AnimatedSprite.flip_h = velocity.x < 0
	else:
		$AnimatedSprite.animation = "up"
		$AnimatedSprite.flip_v = velocity.y > 0

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite.play()
	else:
		$AnimatedSprite.stop()

	position += velocity * delta
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)



func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false


func _on_Player_body_entered(_body):
	hide() # Player disappears after being hit.
	emit_signal("hit")
	# Must be deferred as we can't change physics properties on a physics callback.
	$CollisionShape2D.set_deferred("disabled", true)

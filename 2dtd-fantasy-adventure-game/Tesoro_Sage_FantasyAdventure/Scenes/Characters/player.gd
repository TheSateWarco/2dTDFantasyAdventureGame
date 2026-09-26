extends CharacterBody2D
@export var speed = 200
@onready var animatedSprite = $AnimatedSprite2D
@onready var lastDirection = "Down"
@onready var is_action_playing = false

func _physics_process(_delta):
	
	var inputDirection = Input.get_vector("moveLeft", "moveRight", "moveUp",
	"moveDown")
	
	velocity = inputDirection * speed
	update_direction(inputDirection)
	if not is_action_playing:
		update_movement_animation(inputDirection)
	move_and_slide()
	
func update_movement_animation(input_direction):
	if input_direction == Vector2.ZERO:
		animatedSprite.play("idle" + lastDirection)
	else:
		animatedSprite.play("run" + lastDirection)
		
func play_action_animation(action_name):
	is_action_playing = true
	animatedSprite.play(action_name + lastDirection)
	
func update_direction(input_direction):
	if input_direction.y < 0:
		lastDirection = "Up"
	elif input_direction.y > 0:
		lastDirection = "Down"
	elif input_direction.x < 0:
		lastDirection = "Left"
	elif input_direction.x > 0:
		lastDirection = "Right"
		
func _unhandled_input(event):
	if event.is_action_pressed("attack"):
		play_action_animation("attack")
	elif event.is_action_pressed("testHit"):
		play_action_animation("hit")
	elif event.is_action_pressed("testDie"):
		play_action_animation("die")

func _on_animated_sprite_2d_animation_finished():
	is_action_playing = false

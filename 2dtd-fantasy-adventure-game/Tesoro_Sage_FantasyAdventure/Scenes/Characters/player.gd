extends CharacterBody2D
@export var speed = 200
@onready var animated_sprite = $AnimatedSprite2D
@onready var last_direction = "down"

func _physics_process(_delta):
	
	var input_direction = Input.get_vector("moveLeft", "moveRight", "moveUp",
	"moveDown")
	
	velocity = input_direction * speed
	update_direction(input_direction)
	move_and_slide()
	
func update_movement_animation(input_direction):
	if input_direction == Vector2.ZERO:
		animated_sprite.play("idle_" + last_direction)
	
func update_direction(input_direction):
	if input_direction.y < 0:
		last_direction = "up"
	elif input_direction.y > 0:
		last_direction = "down"
	elif input_direction.x < 0:
		last_direction = "left"
	elif input_direction.x > 0:
		last_direction = "right"

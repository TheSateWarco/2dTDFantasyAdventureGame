extends CharacterBody2D
@export var speed = 200
@onready var animated_sprite = $AnimatedSprite2D

func _physics_process(delta):
	var input_direction = Input.get_vector("moveLeft", "moveRight", "moveUp",
	"moveDown")

	velocity = input_direction * speed

	move_and_slide()

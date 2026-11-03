extends CharacterBody2D
@export var speed:float = 200.0
@onready var animatedSprite = $AnimatedSprite2D
@onready var lastDirection = "Down"
@onready var is_action_playing = false
@onready var max_health: int = 100
@onready var health: int = 100
signal health_changed(new_health)

@export var attack_distance: float = 20.0
var facing_direction: Vector2 = Vector2.DOWN


@onready var HurtSound: AudioStreamPlayer2D = $HurtSound
@onready var SwordSlashSound: AudioStreamPlayer2D = $SwordSlashSound

var is_dead: bool = false

func take_damage(amount: int):
	if is_dead:
		return

	HurtSound.play()
	health -= amount
	health = max(health, 0)
	health_changed.emit(health)

	if health <= 0:
		die()
	else:
		play_action_animation("hit")
		
func die():
	if is_dead:
		return

	is_dead = true
	velocity = Vector2.ZERO
	play_action_animation("die")

var knockback_velocity: Vector2 = Vector2.ZERO

@export var knockback_strength: float = 400.0
@export var knockback_friction: float = 800.0

func apply_knockback(source_position: Vector2):
	var knockback_direction = global_position - source_position
	knockback_direction = knockback_direction.normalized()

	knockback_velocity = knockback_direction * knockback_strength

func _physics_process(delta):
	if is_dead:
		velocity = Vector2.ZERO
		return


	var inputDirection = Input.get_vector(
		"moveLeft", "moveRight", "moveUp", "moveDown"
	)

	velocity = inputDirection * speed
	
	if inputDirection != Vector2.ZERO:
		update_direction(inputDirection)

		match lastDirection:
			"Up":
				facing_direction = Vector2.UP
			"Down":
				facing_direction = Vector2.DOWN
			"Left":
				facing_direction = Vector2.LEFT
			"Right":
				facing_direction = Vector2.RIGHT

	$AttackArea.position = facing_direction * attack_distance

	# Apply knockback
	velocity += knockback_velocity
	knockback_velocity = knockback_velocity.move_toward(
		Vector2.ZERO,
		knockback_friction * delta
	)

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
	if is_dead:
		return
	if event.is_action_pressed("attack"):
		play_action_animation("attack")
		SwordSlashSound.play()
		attack()  # Damage enemies inside the hitbox

	elif event.is_action_pressed("testHit"):
		play_action_animation("hit")

	elif event.is_action_pressed("testDie"):
		play_action_animation("die")

func _on_animated_sprite_2d_animation_finished():
	if is_dead:
		return

	is_action_playing = false

func attack() -> void:
	for body in $AttackArea.get_overlapping_bodies():
		if body.is_in_group("enemies") and body.has_method("take_damage"):
			body.take_damage(1)

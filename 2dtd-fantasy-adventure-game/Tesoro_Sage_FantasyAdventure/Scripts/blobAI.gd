
extends CharacterBody2D

enum State { IDLE, PATROL, CHASE, SEARCH, ATTACK }

@export_group("Movement")
@export var patrol_speed: float = 40.0
@export var chase_speed: float = 70.0

@export_group("Timing")
@export var idle_time: float = 2.0
@export var patrol_distance: float = 100.0
@export var search_wait_time: float = 1.0
var search_timer: float = 0.0
var last_known_player_location: Vector2 = Vector2.ZERO



var current_state: State = State.IDLE
var player: CharacterBody2D = null

var patrol_points: Array[Vector2] = []
var patrol_index: int = 0
var idle_timer: float = 0.0
var chase_timer: float = 0.0
var is_patrolling: bool = false
var lastKnownPlayerLocation = Vector2.ZERO

@onready var detectionArea: Area2D = $DetectionArea


func _ready():
	# Create two patrol points around the starting position.
	patrol_points = [
		global_position,
		global_position + Vector2(patrol_distance, 0)
	]

	idle_timer = idle_time
	current_state = State.IDLE

	detectionArea.body_entered.connect(_on_body_entered)
	detectionArea.body_exited.connect(_on_body_exited)


func _physics_process(delta):
	match current_state:
		State.IDLE:
			velocity = Vector2.ZERO
			idle_timer -= delta

			if idle_timer <= 0:
				current_state = State.PATROL

		State.PATROL:
			patrol()

		State.CHASE:
			chase_player()

		State.SEARCH:
			search_last_location(delta)

	move_and_slide()



func patrol():
	var target = patrol_points[patrol_index]
	var direction = global_position.direction_to(target)

	velocity = direction * patrol_speed

	# Check whether the Blob reached its patrol point.
	if global_position.distance_to(target) < 5.0:
		velocity = Vector2.ZERO

		# Switch to the other patrol point.
		patrol_index = (patrol_index + 1) % patrol_points.size()

		# Stop patrolling and idle before moving again.
		idle_timer = idle_time
		current_state = State.IDLE

func chase_player():
	if not is_instance_valid(player):
		player = null
		current_state = State.SEARCH
		return

	last_known_player_location = player.global_position

	var direction = global_position.direction_to(
		last_known_player_location
	)

	velocity = direction * chase_speed

	direction = global_position.direction_to(
		player.global_position
	)
	lastKnownPlayerLocation = direction

	velocity = direction * chase_speed

func search_last_location(delta):
	var distance = global_position.distance_to(
		last_known_player_location
	)

	if distance > 5.0:
		var direction = global_position.direction_to(
			last_known_player_location
		)
		velocity = direction * chase_speed
	else:
		velocity = Vector2.ZERO
		search_timer -= delta

		if search_timer <= 0:
			idle_timer = idle_time
			current_state = State.IDLE

func _on_body_entered(body: Node2D):
	if body is CharacterBody2D and body.is_in_group("player"):
		player = body
		current_state = State.CHASE
		



func _on_body_exited(body: Node2D):
	if body == player:
		last_known_player_location = player.global_position
		player = null
		search_timer = search_wait_time
		current_state = State.SEARCH
		
func take_damage(amount: int) -> void:
# If you decide to add an enemy health variable later, manage it here
# For now, let's just make it die instantly upon a player strike
	die()
	
func die() -> void:
# Safely vanish the monster scene tree instance cleanly between engine steps
	queue_free()

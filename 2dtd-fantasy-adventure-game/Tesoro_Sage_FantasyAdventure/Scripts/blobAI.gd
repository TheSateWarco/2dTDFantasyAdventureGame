
extends CharacterBody2D

enum State { IDLE, PATROL, CHASE }

@export var patrol_speed: float = 40.0
@export var chase_speed: float = 90.0
@export var idle_time: float = 2.0
@export var patrol_distance: float = 100.0

var current_state: State = State.IDLE
var player: CharacterBody2D = null

var patrol_points: Array[Vector2] = []
var patrol_index: int = 0
var idle_timer: float = 0.0
var is_patrolling: bool = false

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
		current_state = State.PATROL
		velocity = Vector2.ZERO
		return

	var direction = global_position.direction_to(
		player.global_position
	)

	velocity = direction * chase_speed


func _on_body_entered(body: Node2D):
	if body is CharacterBody2D and body.is_in_group("player"):
		player = body
		current_state = State.CHASE


func _on_body_exited(body: Node2D):
	if body == player:
		player = null
		current_state = State.PATROL

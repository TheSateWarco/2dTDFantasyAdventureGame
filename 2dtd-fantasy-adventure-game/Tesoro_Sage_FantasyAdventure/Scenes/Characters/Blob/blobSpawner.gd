
extends Node2D

# 1. Configuration Exports
@export var blob_scene: PackedScene # Drag and drop BlobMonster.tscn here
@export var spawn_cooldown: float = 4.0 # Time between spawn attempts
@export var max_blobs_alive: int = 5 # Maximum number of blobs alive


# 2. Tracking Properties
var spawn_points: Array[Marker2D] = []
var active_blobs: Array[CharacterBody2D] = []

@onready var spawn_timer: Timer = $SpawnTimer


func _ready() -> void:
	# 1. Automatically collect all child Marker2D nodes
	for child in get_children():
		if child is Marker2D:
			spawn_points.append(child)
			
	# If no markers exist, create a default spawn point
	if spawn_points.is_empty():
		var default_marker = Marker2D.new()
		add_child(default_marker)
		spawn_points.append(default_marker)

	# 2. Initialize the spawn timer
	spawn_timer.wait_time = spawn_cooldown
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	spawn_timer.start()


func _on_spawn_timer_timeout() -> void:
	# 3. Remove blobs that have been freed
	active_blobs = active_blobs.filter(
		func(blob): return is_instance_valid(blob)
	)

	# 4. Enforce the maximum population
	if active_blobs.size() >= max_blobs_alive:
		return # Skip this spawn attempt if the map is full

	if blob_scene:
		spawn_new_blob()



func spawn_new_blob() -> void:
	if spawn_points.is_empty() or blob_scene == null:
		return

	# Pick a random spawn marker
	var random_marker: Marker2D = spawn_points.pick_random()

	# Instantiate the blob
	var new_blob = blob_scene.instantiate() as CharacterBody2D
	if new_blob == null:
		return

	new_blob.add_to_group("enemies")

	# Add it to the level first
	get_parent().add_child(new_blob)

	# Position it at the marker's global position
	new_blob.global_position = random_marker.global_position

	# Track the blob
	active_blobs.append(new_blob)

	# Play spawn animation
	trigger_spawn_juice(new_blob)




func trigger_spawn_juice(target_blob: CharacterBody2D) -> void:
	var blob_sprite = target_blob.get_node_or_null("Sprite2D")

	if blob_sprite:
		var original_scale: Vector2 = blob_sprite.scale

		# Start invisible in size, preserving the original scale
		blob_sprite.scale = Vector2.ZERO

		var spawn_tween = create_tween()
		spawn_tween.tween_property(
			blob_sprite,
			"scale",
			original_scale * 1.3,
			0.15
		)
		spawn_tween.tween_property(
			blob_sprite,
			"scale",
			original_scale,
			0.1
		)

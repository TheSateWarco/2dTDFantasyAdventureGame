
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
	# 5. Pick a random spawn location
	var random_marker = spawn_points.pick_random()
	print(random_marker)
	# 6. Instantiate the blob scene
	var new_blob = blob_scene.instantiate() as CharacterBody2D
	new_blob.add_to_group("enemies")
	# 7. Set the blob's global position
	new_blob.global_position = random_marker.global_position
	
	# 8. Track the blob and add it to the active level
	active_blobs.append(new_blob)
	get_parent().add_child.call_deferred(new_blob)

	# Optional: Play a spawn animation
	trigger_spawn_juice(new_blob)


func trigger_spawn_juice(target_blob: CharacterBody2D) -> void:
	# Find the blob's sprite
	var blob_sprite = target_blob.get_node_or_null("Sprite2D")

	if blob_sprite:
		# Animate the sprite as it emerges
		var spawn_tween = create_tween()
		blob_sprite.scale = Vector2.ZERO

		spawn_tween.tween_property(
			blob_sprite, "scale", Vector2(1.3, 1.3), 0.15
		)
		spawn_tween.tween_property(
			blob_sprite, "scale", Vector2(1.0, 1.0), 0.1
		)

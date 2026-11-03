class_name Minimap
extends Panel

## The node the map is centered on. Drag your Player here in the Inspector.
@export var player: Node2D

## How much the world is shrunk. 0.1 means 10 world pixels become 1 map pixel.
@export_range(0.01, 1.0, 0.01) var map_scale := 0.1

## Radius of each dot, in pixels.
@export var dot_size := 3.0

@export_group("Colors")
@export var background_color := Color(0, 0, 0, 0.6)
@export var border_color := Color(1, 1, 1, 0.8)
@export var player_color := Color.WHITE
@export var monster_color := Color.RED
@export var coin_color := Color.GOLD


func _ready() -> void:
	# Hide anything drawn outside the panel's rectangle.
	clip_contents = true


func _process(_delta: float) -> void:
	# Things move every frame, so ask Godot to call _draw() again.
	queue_redraw()


func _draw() -> void:
	var map_rect := Rect2(Vector2.ZERO, size)
	draw_rect(map_rect, background_color)

	if player != null:
		_draw_group("coins", coin_color)
		_draw_group("enemies", monster_color)

	# The player is always in the middle of the map.
	draw_circle(size / 2, dot_size + 1.0, player_color)

	# Outline drawn last so it sits on top of the dots.
	draw_rect(map_rect, border_color, false, 2.0)


func _draw_group(group_name: String, color: Color) -> void:
	for node in get_tree().get_nodes_in_group(group_name):
		if not node is Node2D:
			continue

		var map_pos := _world_to_map(node.global_position)

		if Rect2(Vector2.ZERO, size).has_point(map_pos):
			draw_circle(map_pos, dot_size, color)


func _world_to_map(world_pos: Vector2) -> Vector2:
	# 1. Position relative to the player. 2. Shrink it. 3. Move it to the map's center.
	return (world_pos - player.global_position) * map_scale + size / 2

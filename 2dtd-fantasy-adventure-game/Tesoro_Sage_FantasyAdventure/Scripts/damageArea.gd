extends Area2D

@export var damage: int = 10

var player: CharacterBody2D

func _ready():
	print("DamageArea is ready!")

	player = get_parent() as CharacterBody2D

	if player == null:
		print("ERROR: DamageArea parent is not the Player!")
		return

	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D):
	print("Detected node: ", body.name)
	print("Node path: ", body.get_path())
	print("Groups: ", body.get_groups())

	if body.is_in_group("enemies"):
		player.take_damage(damage)
		print("Player health: ", player.health)

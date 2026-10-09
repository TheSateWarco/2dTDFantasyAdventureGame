extends ProgressBar

@onready var player = get_node("/root/MainGameLvl/Player")

func _ready():
	max_value = player.max_health
	value = player.health

	player.health_changed.connect(_on_health_changed)

func _on_health_changed(new_health):
	value = new_health

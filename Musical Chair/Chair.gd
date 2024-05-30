extends Area2D

var occupied = false

@onready var collision_shape = $CollisionShape2D

func _ready():
	reset()

func reset():
	collision_shape.disabled = true  # Disable collision until music stops
	occupied = false

func _on_body_entered(body):
	if not occupied and (body.is_in_group("Player") or body.is_in_group("Enemy")):
		var animation_tree = body.get_node("AnimationTree")
		# Get the ChairManager from the current level node
		var chair_manager = get_tree().get_root().get_node("Game").current_level.get_node("ChairManager")
		chair_manager.on_chair_occupied(self, body, animation_tree)
		print("Chair occupied by " + body.name)

func enable_collision():
	collision_shape.disabled = false

extends Area2D

var occupied = false
var interactable = false

@onready var collision_shape = $CollisionShape2D

func _ready():
	collision_shape.disabled = true  # Disable collision until music stops

func _on_body_entered(body):
	if not occupied and body.is_in_group("Player"):
		occupied = true
		body.on_chair_occupied(global_position)
		print("Chair occupied by Player")

func enable_collision():
	collision_shape.disabled = false
	interactable = true

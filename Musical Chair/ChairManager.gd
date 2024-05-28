extends Node2D

var total_chairs: int = 0
var occupied_chairs: int = 0

func _ready():
	# Initialize the total number of chairs
	total_chairs = get_tree().get_root().get_node("Game/Level1/Chairs").get_children().size()
	occupied_chairs = 0

func on_chair_occupied(chair: Node2D, occupant: Node2D, animation_tree: AnimationTree):
	if chair.occupied:
		return  # If the chair is already occupied, do nothing
	chair.occupied = true
	occupied_chairs += 1

	occupant.global_position = chair.global_position
	occupant.velocity = Vector2.ZERO
	occupant.scale *= 1.5
	
	animation_tree.set("parameters/Idle/blend_position", Vector2(0, 1))
	animation_tree.set("parameters/Walk/blend_position", Vector2(0, 1))
	
	occupant.set_physics_process(false)  # Stop the physics process to keep the occupant stationary

	if occupant.is_in_group("Player"):
		print("Player occupied the chair")
	elif occupant.is_in_group("Enemy"):
		occupant.fsm.change_state(null)  # Stop further state transitions
		print("Enemy occupied the chair")

	if occupied_chairs >= total_chairs:
		print("Player Lost!")

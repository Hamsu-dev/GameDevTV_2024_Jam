extends Node2D

var total_chairs: int = 0
var occupied_chairs: int = 0

@onready var player = get_tree().get_root().get_node("Game/Level1/Player")

func _ready():
	# Initialize the total number of chairs
	total_chairs = get_tree().get_root().get_node("Game/Level1/Chairs").get_children().size()
	occupied_chairs = 0

func on_chair_occupied(chair: Node2D, occupant: Node2D, animation_tree: AnimationTree):
	print("Chair occupied")
	if chair.occupied:
		return  # If the chair is already occupied, do nothing
	chair.occupied = true
	occupied_chairs += 1

	# Move the occupant to the chair's position
	occupant.global_position = chair.global_position
	occupant.velocity = Vector2.ZERO
	occupant.scale *= 1.5
	
	# Set the animation tree blend position
	animation_tree.set("parameters/Idle/blend_position", Vector2(0, 1))
	animation_tree.set("parameters/Walk/blend_position", Vector2(0, 1))
	
	# Stop the physics process to keep the occupant stationary
	occupant.set_physics_process(false)

	# Defer the changes to avoid the flushing queries issue
	call_deferred("_finalize_chair_occupation", chair, occupant, animation_tree)

func _finalize_chair_occupation(_chair: Node2D, occupant: Node2D, _animation_tree: AnimationTree):
	# If the occupant is an enemy, stop further state transitions and disable collision
	if occupant.is_in_group("Enemy"):
		occupant.fsm.change_state(null)  # Stop further state transitions
		var enemy_collision_shape = occupant.get_node("CollisionShape2D")
		enemy_collision_shape.disabled = true  # Disable enemy collision
		print("Enemy occupied the chair")
		
		# Ensure the enemy stops all interactions
		disable_enemy_interactions(occupant)

	if occupant.is_in_group("Player"):
		print("Player occupied the chair")
		disable_player_interactions(occupant)
		occupant.chair_occupied = true  # Set player's chair_occupied state to true

	# Check if all chairs are occupied
	check_game_over()

func disable_enemy_interactions(enemy):
	# Disable all interactions for the enemy
	enemy.ray_cast_2d.enabled = false  # Disable raycast
	enemy.contact_area.body_entered.disconnect(enemy._on_knockback_detection_body_entered)  # Disable knockback detection
	enemy.collision_shape_2d.disabled = true  # Disable collision shape

func disable_player_interactions(_player):
	# Add any player-specific interaction disabling if needed
	player.chair_occupied = true

func check_game_over():
	var all_chairs_occupied = true
	for chair in get_tree().get_root().get_node("Game/Level1/Chairs").get_children():
		if not chair.occupied:
			all_chairs_occupied = false
			break

	if all_chairs_occupied and not player.chair_occupied:
		print("YOU LOSE")
		player.set_process(false)  # Optionally stop player movement
		change_to_lose_screen()

func change_to_lose_screen():
	SceneManager.change_scene("res://lose_screen.tscn")

class_name Enemy
extends EnemyBase

var is_rushing_to_chair = false  # New flag to track rush-to-chair state

func _ready():
	enemy_wander_state.found_player.connect(fsm.change_state.bind(enemy_chase_state))
	enemy_chase_state.lost_player.connect(fsm.change_state.bind(enemy_wander_state))
	exclamation_mark.hide()
	
	# Connect to the music_stopped signal
	var game_manager = get_tree().root.get_node("Game")
	game_manager.music_stopped.connect(_on_music_stopped)

func _on_music_stopped():
	if not chair_occupied and not is_rushing_to_chair:  # Only change state if the enemy has not occupied a chair
		fsm.change_state(enemy_rush_to_chair_state)
		is_rushing_to_chair = true

func _on_knockback_detection_body_entered(body):
	if body.is_in_group("Player") and not chair_occupied:
		var knockback_direction = (body.global_position - global_position).normalized()
		body.call("apply_knockback", knockback_direction * knockback_strength)

func _on_detection_body_entered(body):
	if body.is_in_group("Player") and not is_rushing_to_chair:  # Prevent switching to chase state
		player = body
		if can_see_target(body):
			enemy_wander_state.found_player.emit()
			exclamation_mark.show()

func _on_detection_body_exited(body):
	if body.is_in_group("Player"):
		player = null
		if not can_see_target(body):
			enemy_chase_state.lost_player.emit()
			exclamation_mark.hide()

func can_see_target(target: Node2D) -> bool:
	ray_cast_2d.global_position = global_position
	ray_cast_2d.target_position = target.global_position - global_position
	ray_cast_2d.force_raycast_update()
	return not ray_cast_2d.is_colliding()

func _physics_process(_delta):
	if player and not can_see_target(player):
		enemy_chase_state.lost_player.emit()
		player = null

func reset_state():
	chair_occupied = false
	is_rushing_to_chair = false  # Reset the flag when the state is reset
	collision_shape_2d.disabled = false  # Enable collision shape
	set_physics_process(true)
	print("Enemy state reset")

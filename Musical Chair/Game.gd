extends Node2D

@onready var chairs = $Level1/Chairs.get_children()
@onready var player = $Level1/Player
@onready var music_player = $Level1/AudioStreamPlayer2D
@onready var chair_timer = $Level1/ChairRandomTimer
@onready var level_1 = $Level1
@onready var room = $Level1/Control/Room
@onready var tilemap = $Level1/BlockTileMap

var play_area_size: Vector2 = Vector2(320, 180)
var play_area_position: Vector2
var game_state = "music_playing" # other state is "music_stopped"

# Define the wall tile ID
var wall_tile_id = 2
var ground_tile_id = 1

signal music_stopped

func _ready():
	play_area_position = room.position
	start_music()

func start_music():
	music_player.play()
	game_state = "music_playing"
	start_randomizing_chairs()
	for chair in chairs:
		chair.occupied = false
		chair.collision_shape.disabled = true  # Disable chair collisions
	player.chair_occupied = false
	print("Music playing! Chairs are not accessible yet.")

func _on_audio_stream_player_2d_finished():
	game_state = "music_stopped"
	stop_randomizing_chairs()
	player.chair_occupied = false
	for chair in chairs:
		chair.enable_collision()  # Enable chair collisions
	print("Music stopped! Find a chair!")
	music_stopped.emit()
	check_game_over()

func start_randomizing_chairs():
	chair_timer.start(2.0)  # Randomize every 2 seconds (adjust as needed)

func stop_randomizing_chairs():
	chair_timer.stop()

func _on_chair_random_timer_timeout():
	randomize_chair_positions()

func randomize_chair_positions():
	for chair in chairs:
		var valid_position = false
		while not valid_position:
			var new_position = Vector2(
				randi() % int(play_area_size.x) + play_area_position.x,
				randi() % int(play_area_size.y) + play_area_position.y
			)
			if is_position_walkable(new_position):
				chair.global_position = new_position

				# Check for collisions
				if not chair.get_overlapping_bodies():
					valid_position = true

func is_position_walkable(new_chair_position: Vector2) -> bool:
	var tile_pos = tilemap.local_to_map(new_chair_position)
	var tile_id = tilemap.get_cell_source_id(0, tile_pos)
	return tile_id == ground_tile_id

func on_chair_occupied(chair: Node2D, occupant: Node2D, animation_tree: AnimationTree):
	if chair.occupied:
		return  # If the chair is already occupied, do nothing
	chair.occupied = true

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
		var enemy_collision_shape = occupant.get_node("CollisionShape2D")
		if enemy_collision_shape:
			enemy_collision_shape.disabled = true  # Disable enemy collision
		print("Enemy occupied the chair")

	check_game_over()

func check_game_over():
	var all_chairs_occupied = true
	for chair in chairs:
		if not chair.occupied:
			all_chairs_occupied = false
			break

	if all_chairs_occupied:
		print("Player Lost!")
		player.set_process(false)  # Optionally stop player movement

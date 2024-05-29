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

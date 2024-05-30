extends Node2D

@export var min_chair_distance: int = 50  # Minimum distance between chairs
@export var max_chair_distance: int = 150  # Maximum teleportation range
@export var stuck_check_interval: float = 5.0  # Interval to check if the enemies are stuck

@onready var player = $Player
@onready var chair_timer = $ChairTimer
@onready var music_level_1 = $MusicLevel1
@onready var music_level_2 = $MusicLevel2
@onready var music_level_3 = $MusicLevel3
@onready var stuck_timer = $StuckTimer


var play_area_size: Vector2
var play_area_position: Vector2
var game_state = "music_playing"
var current_level
var chair_manager
var current_music_player = null
var active_debuffs = []

# Define the wall tile ID
var wall_tile_id = 2
var ground_tile_id = 1

signal music_stopped

func _ready():
	initialize_level("res://level_1.tscn", false, 2.0)  # Initial level with no random chair, default interval

func initialize_level(level_path: String, randomize_chairs: bool, chair_timer_interval: float):
	if current_level:
		current_level.queue_free()
	
		for debuff in active_debuffs:
			debuff.queue_free()
		active_debuffs.clear()
		
	current_level = load(level_path).instantiate()
	add_child(current_level)

	play_area_size = current_level.get_node("Control/Room").size
	play_area_position = current_level.get_node("Control/Room").position
	var chairs = current_level.get_node("Chairs").get_children()
	chair_manager = current_level.get_node("ChairManager")
	chair_manager.initialize(chairs, player)
	
	player.reset_state()
	place_player_on_walkable_tile()
	reset_enemies()
	
	chair_manager.game_over_lost.connect(_on_game_over_lost)
	chair_manager.game_over_won.connect(_on_game_over_won)

	start_music(level_path, randomize_chairs, chair_timer_interval)

func start_music(level_path: String, randomize_chairs: bool, chair_timer_interval: float):
	if current_music_player:
		current_music_player.stop()
		current_music_player.finished.disconnect(_on_audio_stream_player_finished)

	if level_path == "res://level_1.tscn":
		current_music_player = music_level_1
	elif level_path == "res://level_2.tscn":
		current_music_player = music_level_2
	elif level_path == "res://level_3.tscn":
		current_music_player = music_level_3

	if current_music_player:
		current_music_player.finished.connect(_on_audio_stream_player_finished)
		current_music_player.play()

	game_state = "music_playing"
	if randomize_chairs:
		start_randomizing_chairs(chair_timer_interval)
	for chair in chair_manager.chairs:
		chair.occupied = false
		chair.collision_shape.disabled = true
	player.chair_occupied = false
	print("Music playing! Chairs are not accessible yet.")

func _on_audio_stream_player_finished():
	game_state = "music_stopped"
	stop_randomizing_chairs()
	player.chair_occupied = false
	for chair in chair_manager.chairs:
		chair.enable_collision()
	print("Music stopped! Find a chair!")
	emit_signal("music_stopped")

	for enemy in current_level.get_node("Enemy").get_children():
		enemy._on_music_stopped()

	# Start the stuck check timer
	stuck_timer.start(stuck_check_interval)

func start_randomizing_chairs(chair_timer_interval: float):
	chair_timer.start(chair_timer_interval)

func stop_randomizing_chairs():
	chair_timer.stop()

func _on_chair_timer_timeout():
	randomize_chair_positions()

func randomize_chair_positions():
	for chair in chair_manager.chairs:
		var valid_position = false
		while not valid_position:
			var new_position = Vector2(
				randi() % int(play_area_size.x) + play_area_position.x,
				randi() % int(play_area_size.y) + play_area_position.y
			)
			if is_position_walkable(new_position) and is_position_far_enough(new_position):
				chair.global_position = new_position
				if not chair.get_overlapping_bodies():
					valid_position = true

func is_position_walkable(new_chair_position: Vector2) -> bool:
	var tilemap = current_level.get_node("BlockTileMap")
	var tile_pos = tilemap.local_to_map(new_chair_position)
	var tile_id = tilemap.get_cell_source_id(0, tile_pos)
	return tile_id == ground_tile_id

func is_position_far_enough(new_position: Vector2) -> bool:
	for chair in chair_manager.chairs:
		if chair.global_position.distance_to(new_position) < min_chair_distance:
			return false
	return true

func place_player_on_walkable_tile():
	print("spawning player")
	var valid_position = false
	while not valid_position:
		var new_position = Vector2(
			randi() % int(play_area_size.x) + play_area_position.x,
			randi() % int(play_area_size.y) + play_area_position.y
		)
		if is_position_walkable(new_position):
			player.global_position = new_position
			valid_position = true

func reset_enemies():
	var enemies = current_level.get_node("Enemy").get_children()
	for enemy in enemies:
		enemy.reset_state()

func change_levels(level_path):
	var randomize_chairs = (level_path != "res://level_1.tscn")
	var chair_timer_interval = 2.0  # Default interval
	if level_path == "res://level_3.tscn":
		chair_timer_interval = 0.5  # Faster interval for level 3
	initialize_level(level_path, randomize_chairs, chair_timer_interval)

func _on_game_over_lost():
	SceneManager.change_scene("res://MainMenu.tscn")

func _on_game_over_won():
	if current_level.scene_file_path == "res://level_1.tscn":
		change_levels("res://level_2.tscn")
	elif current_level.scene_file_path == "res://level_2.tscn":
		change_levels("res://level_3.tscn")
	else:
		change_levels("res://MainMenu.tscn")

func _on_stuck_timer_timeout():
	if player.chair_occupied:
		var all_chairs_occupied = true
		for chair in chair_manager.chairs:
			if not chair.occupied:
				all_chairs_occupied = false
				break

		if not all_chairs_occupied:
			print("Enemies are stuck, moving to the next level.")
			_on_game_over_won()  # Simulate game won if enemies are stuck and player is on chair

func add_debuff(debuff):
	active_debuffs.append(debuff)

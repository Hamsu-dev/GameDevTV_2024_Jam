extends Node2D

@onready var chairs = $Chairs.get_children()
@onready var player = $Player
@onready var music_player = $AudioStreamPlayer2D

var game_state = "music_playing" # other state is "music_stopped"

func _ready():
	start_music()

func start_music():
	music_player.play()
	game_state = "music_playing"
	for chair in chairs:
		chair.occupied = false
		chair.collision_shape.disabled = true  # Disable chair collisions
	player.chair_occupied = false
	print("Music playing! Chairs are not accessible yet.")

func _on_audio_stream_player_2d_finished():
	game_state = "music_stopped"
	player.chair_occupied = false
	for chair in chairs:
		chair.enable_collision()  # Enable chair collisions
	print("Music stopped! Find a chair!")

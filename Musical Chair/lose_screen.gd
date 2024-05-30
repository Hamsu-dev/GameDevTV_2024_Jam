extends Control

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var animated_sprite_2d_2 = $AnimatedSprite2D2
@onready var animated_sprite_2d_3 = $AnimatedSprite2D3
@onready var audio_stream_player_2d = $AudioStreamPlayer2D


func _ready():
	animated_sprite_2d.play("default")
	animated_sprite_2d_2.play("default")
	animated_sprite_2d_3.play("default")
	audio_stream_player_2d.play()
	
	
func _on_texture_button_pressed():
	get_tree().change_scene_to_file("res://world.tscn")


func _on_discord_pressed():
	OS.shell_open("https://discord.gg/GmAej5bWgu")


func _on_insta_pressed():
	OS.shell_open("https://www.instagram.com/s1_lui/")


func _on_itch_pressed():
	OS.shell_open("https://hamsu-dev.itch.io/")


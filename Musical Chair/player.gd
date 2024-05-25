class_name Player
extends CharacterBody2D

# Onready
@onready var animation_tree = $AnimationTree
@onready var playback = animation_tree.get("parameters/playback")

# Variables
var speed = 200
var direction = Vector2.ZERO

# Functions
func _physics_process(_delta):
	move()

func move():
	direction = Input.get_vector("left", "right", "up", "down")
	
	if direction != Vector2.ZERO:
		direction = direction.normalized()
		animation_tree.set("parameters/Idle/blend_position", direction)
		animation_tree.set("parameters/Walk/blend_position", direction)
		playback.travel("Walk")
		velocity = direction * speed

	if direction == Vector2.ZERO:
		playback.travel("Idle")
		velocity = Vector2.ZERO
	
	move_and_slide()

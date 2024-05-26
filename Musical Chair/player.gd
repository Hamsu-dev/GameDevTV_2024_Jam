class_name Player
extends CharacterBody2D

# Onready
@onready var animation_tree = $AnimationTree
@onready var playback = animation_tree.get("parameters/playback")
@onready var sprite_2d = $Sprite2D

# Variables
@export var speed : float = 70

var direction : Vector2 = Vector2.ZERO
var knockback : Vector2 = Vector2.ZERO
var knockbackTween

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
	
	velocity += knockback
	move_and_slide()

func _hit(knockback_strength : Vector2 = Vector2(0,0), stop_time : float = 0.25):
	if knockback_strength != Vector2.ZERO:
		# Start at max strength
		knockback = knockback_strength
		
		# Resets knockback if active knockback
		if knockbackTween:
			knockbackTween.kill()	
		
		# Decreasing knockback strength to 0 over stop_time duration
		knockbackTween = get_tree().create_tween()
		knockbackTween.parallel().tween_property(self, "knockback", Vector2.ZERO, stop_time)
		
		# Modulate color - red to white
		sprite_2d.modulate = Color(1,0,0,1)
		knockbackTween.parallel().tween_property(sprite_2d, "modulate", Color(1,1,1,1), stop_time)

func _input(event):
	if Input.is_action_just_pressed("ui_accept"):
		_hit(Vector2(0, 300))

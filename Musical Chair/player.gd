class_name Player2
extends CharacterBody2D

@onready var animation_tree = $AnimationTree
@onready var playback = animation_tree.get("parameters/playback")
@onready var sprite_2d = $Sprite2D
@onready var chair_detection = $ChairDetection
@onready var collision_shape_2d = $CollisionShape2D

@export var speed : float = 70

# Speed_PowerUp
var base_speed: float = 100.0
var speed_boost_active: bool = false
var slow_debuff_active: bool = false

# Variables
var direction : Vector2 = Vector2.ZERO
var knockback : Vector2 = Vector2.ZERO
var knockbackTween
var chair_occupied = false
var near_chair = null

func _physics_process(_delta):
	if chair_occupied:
		velocity = Vector2.ZERO
	else:
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

func apply_knockback(knockback_vector: Vector2):
	_hit(knockback_vector)

func on_chair_occupied(chair_position: Vector2):
	# Teleport player to the chair's position
	global_position = chair_position
	chair_occupied = true
	playback.travel("Idle")
	velocity = Vector2.ZERO
	scale *= 1.5
	animation_tree.set("parameters/Idle/blend_position", Vector2(0, 1))
	animation_tree.set("parameters/Walk/blend_position", Vector2(0, 1))
	print("You won!")

func _on_chair_detection_area_entered(area):
	if area.is_in_group("Chair"):
		near_chair = area
		print("Player near a chair")

func _on_chair_detection_area_exited(area):
	if area.is_in_group("Chair"):
		near_chair = null
		print("Player left the chair's vicinity")

func apply_speed_boost(duration):
	if not speed_boost_active:
		speed_boost_active = true
		speed *= 2
		await get_tree().create_timer(duration).timeout
		speed = base_speed
		speed_boost_active = false

func apply_slow_debuff(duration, factor):
	if not slow_debuff_active:
		slow_debuff_active = true
		speed *= factor
		await get_tree().create_timer(duration).timeout
		speed = base_speed
		slow_debuff_active = false

func reset_state():
	chair_occupied = false
	scale = Vector2.ONE
	set_physics_process(true)
	animation_tree.set("parameters/Idle/blend_position", Vector2(0, 1))
	animation_tree.set("parameters/Walk/blend_position", Vector2(0, 1))
	collision_shape_2d.disabled = false  # Enable collision shape
	print("Player state reset")

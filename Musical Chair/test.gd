extends CharacterBody2D

@export var move_speed : float = 100
@export var health : float = 3

var knockback : Vector2 = Vector2(0,0)
var knockbackTween 

func _physics_process(_delta):
	# Add forces to rigidbody
	var horiz_axis = Input.get_axis("ui_left", "ui_right")
	var vert_axis = Input.get_axis("ui_up", "ui_down")
	
	var move_direction : Vector2 = Vector2(horiz_axis, vert_axis)
	var movement = move_direction * move_speed
	
	velocity = movement + knockback
	move_and_slide()

	if(Input.is_action_just_pressed("ui_accept")):
		_hit(1, Vector2(300,0))

# Get hit by object with knockback direction
func _hit(damage : float, knockback_strength : Vector2 = Vector2(0,0), stop_time : float = 0.25):
	health -= damage
	
	if(health <= 0):
		# Character died
		queue_free()
	elif (knockback_strength != Vector2(0,0)):
		# Start at max strength
		knockback = knockback_strength
		
		# Resets knockback if active knockback
		# if(knockbackTween):
		#	knockbackTween.kill()	
		
		# Decreasing knockback strength to 0 over stop_time duration
		knockbackTween = get_tree().create_tween()
		knockbackTween.parallel().tween_property(self, "knockback", Vector2(0,0), stop_time)
		
		# Modulate color - red to white
		$Sprite2d.modulate = Color(1,0,0,1)
		knockbackTween.parallel().tween_property($Sprite2d, "modulate", Color(1,1,1,1), stop_time)

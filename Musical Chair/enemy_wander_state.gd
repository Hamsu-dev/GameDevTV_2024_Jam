class_name EnemyWanderState
extends State

@export var actor: Enemy

var animation_tree: AnimationTree
var playback: AnimationNodeStateMachinePlayback

signal found_player

func _ready():
	set_physics_process(false)

func _enter_state() -> void:
	print("Entering Wander State")
	set_physics_process(true)
	
	# Initialize animation_tree and playback here
	animation_tree = actor.animation_tree
	if animation_tree:
		playback = animation_tree.get("parameters/playback")
		if playback:
			playback.travel("Walk")

	if actor.velocity == Vector2.ZERO:
		actor.velocity = Vector2.RIGHT.rotated(randf_range(0, TAU)) * actor.max_speed

func _exit_state() -> void:
	print("Exiting Wander State")
	set_physics_process(false)

func _physics_process(delta):
	var direction = actor.velocity.normalized()
	if direction != Vector2.ZERO:
		if animation_tree:
			animation_tree.set("parameters/Idle/blend_position", direction)
			animation_tree.set("parameters/Walk/blend_position", direction)
			if playback:
				playback.travel("Walk")
	else:
		if playback:
			playback.travel("Walk")
	
	actor.velocity = actor.velocity.move_toward(actor.velocity.normalized() * actor.max_speed, actor.acceleration * delta)
	var collision = actor.move_and_collide(actor.velocity * delta)
	if collision:
		var bounce_velocity = actor.velocity.bounce(collision.get_normal())
		actor.velocity = bounce_velocity

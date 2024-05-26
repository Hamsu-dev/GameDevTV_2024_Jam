class_name EnemyChaseState
extends State

@export var actor: Enemy

var animation_tree: AnimationTree
var playback: AnimationNodeStateMachinePlayback

signal lost_player

func _ready() -> void:
	set_physics_process(false)

func _enter_state() -> void:
	set_physics_process(true)
	
	# Initialize animation_tree and playback here
	animation_tree = actor.animation_tree
	if animation_tree:
		playback = animation_tree.get("parameters/playback")
		if playback:
			playback.travel("Walk")

	# Show the exclamation mark
	actor.exclamation_mark.show()

func _exit_state() -> void:
	set_physics_process(false)

	# Hide the exclamation mark
	actor.exclamation_mark.hide()

func _physics_process(delta) -> void:
	var player = actor.player
	var direction = Vector2.ZERO
	
	if player:
		direction = (player.global_position - actor.global_position).normalized()
		actor.velocity = actor.velocity.move_toward(direction * actor.speed, actor.acceleration * delta)
	else:
		# When the player exits the detection area, the actor should switch to wander state
		emit_signal("lost_player")
		return
	
	if direction != Vector2.ZERO:
		if animation_tree:
			animation_tree.set("parameters/Idle/blend_position", direction)
			animation_tree.set("parameters/Walk/blend_position", direction)
			if playback:
				playback.travel("Walk")
	else:
		if playback:
			playback.travel("Walk")

	var collision = actor.move_and_collide(actor.velocity * delta)
	if collision:
		var bounce_velocity = actor.velocity.bounce(collision.get_normal())
		actor.velocity = bounce_velocity

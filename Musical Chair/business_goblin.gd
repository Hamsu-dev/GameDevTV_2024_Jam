class_name Enemy
extends CharacterBody2D

@export var max_speed = 40.0
@export var acceleration = 50.0
@export var knockback_force : float = 300.0  

@onready var fsm = $FiniteStateMachine as FiniteStateMachine
@onready var enemy_wander_state = $FiniteStateMachine/EnemyWanderState as EnemyWanderState
@onready var enemy_chase_state = $FiniteStateMachine/EnemyChaseState as EnemyChaseState
@onready var ray_cast_2d = $RayCast2D
@onready var animation_tree = $AnimationTree
@onready var playback = animation_tree.get("parameters/playback")
@onready var exclamation_mark = $ExclamationMark  # Add this line to get the ExclamationMark node

var player: Node2D = null
var direction = Vector2.ZERO

func _ready():
	enemy_wander_state.found_player.connect(fsm.change_state.bind(enemy_chase_state))
	enemy_chase_state.lost_player.connect(fsm.change_state.bind(enemy_wander_state))
	
	# Hide the exclamation mark initially
	exclamation_mark.hide()

func _on_detection_body_entered(body):
	if body.is_in_group("Player"):
		player = body
		if can_see_target(body):
			print("Player detected! Switching to chase state.")
			enemy_wander_state.found_player.emit()
			# Show the exclamation mark
			exclamation_mark.show()
		else:
			print("Player detected but not in line of sight.")

func _on_detection_body_exited(body):
	if body.is_in_group("Player"):
		player = null
		# Always switch to wander state when the player exits the detection area
		print("Player lost! Switching to wander state.")
		enemy_chase_state.lost_player.emit()
		# Hide the exclamation mark
		exclamation_mark.hide()

func can_see_target(target: Node2D) -> bool:
	ray_cast_2d.global_position = global_position
	ray_cast_2d.target_position = target.global_position - global_position
	ray_cast_2d.force_raycast_update()
	return not ray_cast_2d.is_colliding()

func _physics_process(_delta):
	if player and not can_see_target(player):
		print("Player lost! Switching to wander state.")
		enemy_chase_state.lost_player.emit()
		player = null

func _hit_player(player: Player):
	var direction = (player.global_position - global_position).normalized()
	var knockback = direction * knockback_force  # Apply force in the opposite direction
	player._hit(knockback)

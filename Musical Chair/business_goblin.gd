class_name Enemy
extends CharacterBody2D

@export var speed = 40.0
@export var acceleration = 50.0
@export var knockback_strength = 300.0

@onready var fsm = $FiniteStateMachine as FiniteStateMachine
@onready var enemy_wander_state = $FiniteStateMachine/EnemyWanderState as EnemyWanderState
@onready var enemy_chase_state = $FiniteStateMachine/EnemyChaseState as EnemyChaseState
@onready var enemy_rush_to_chair_state = $FiniteStateMachine/EnemyRushToChairState as EnemyRushToChairState
@onready var ray_cast_2d = $RayCast2D
@onready var animation_tree = $AnimationTree
@onready var contact_area = $KnockbackDetection
@onready var exclamation_mark = $ExclamationMark
@onready var collision_shape_2d = $CollisionShape2D

var player: Node2D = null
var chair_occupied = false

func _ready():
	enemy_wander_state.found_player.connect(fsm.change_state.bind(enemy_chase_state))
	enemy_chase_state.lost_player.connect(fsm.change_state.bind(enemy_wander_state))
	exclamation_mark.hide()
	
	# Connect to the music_stopped signal
	var game_manager = get_tree().root.get_node("Game")
	game_manager.music_stopped.connect(_on_music_stopped)

func _on_music_stopped():
	if not chair_occupied:  # Only change state if the enemy has not occupied a chair
		fsm.change_state(enemy_rush_to_chair_state)

func _on_knockback_detection_body_entered(body):
	if body.is_in_group("Player"):
		var knockback_direction = (body.global_position - global_position).normalized()
		body.call("apply_knockback", knockback_direction * knockback_strength)

func _on_detection_body_entered(body):
	if body.is_in_group("Player"):
		player = body
		if can_see_target(body):
			enemy_wander_state.found_player.emit()
			exclamation_mark.show()

func _on_detection_body_exited(body):
	if body.is_in_group("Player"):
		player = null
		if not can_see_target(body):
			enemy_chase_state.lost_player.emit()
			exclamation_mark.hide()

func can_see_target(target: Node2D) -> bool:
	ray_cast_2d.global_position = global_position
	ray_cast_2d.target_position = target.global_position - global_position
	ray_cast_2d.force_raycast_update()
	return not ray_cast_2d.is_colliding()

func _physics_process(_delta):
	if player and not can_see_target(player):
		enemy_chase_state.lost_player.emit()
		player = null

func on_chair_occupied(chair_position: Vector2):
	global_position = chair_position
	chair_occupied = true
	velocity = Vector2.ZERO
	scale *= 1.5
	animation_tree.set("parameters/Idle/blend_position", Vector2(0, 1))
	animation_tree.set("parameters/Walk/blend_position", Vector2(0, 1))
	fsm.change_state(null)  # Stop further state transitions
	set_physics_process(false)  # Stop the physics process to keep the enemy stationary

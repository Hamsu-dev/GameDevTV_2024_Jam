class_name Enemy
extends CharacterBody2D

@export var max_speed = 40.0
@export var acceleration = 50.0

@onready var fsm = $FiniteStateMachine as FiniteStateMachine
@onready var enemy_wander_state = $FiniteStateMachine/EnemyWanderState as EnemyWanderState
@onready var enemy_chase_state = $FiniteStateMachine/EnemyChaseState as EnemyChaseState
@onready var detection = $Detection
@onready var ray_cast_2d = $RayCast2D

var player: Node2D = null

func _ready():
	enemy_wander_state.found_player.connect(fsm.change_state.bind(enemy_chase_state))
	enemy_chase_state.lost_player.connect(fsm.change_state.bind(enemy_wander_state))


func _on_detection_body_entered(body):
	if body.is_in_group("Player"):
		player = body
		if can_see_target(body):
			print("Player detected! Switching to chase state.")
			enemy_wander_state.found_player.emit()
		else:
			print("Player detected but not in line of sight.")

func _on_detection_body_exited(body):
	if body.is_in_group("Player"):
		player = null
		if not can_see_target(body):
			print("Player lost! Switching to wander state.")
			enemy_chase_state.lost_player.emit()
		else:
			print("Player still in line of sight.")

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

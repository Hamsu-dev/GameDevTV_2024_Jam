class_name Enemy
extends CharacterBody2D

@export var speed = 40.0
@export var acceleration = 50.0
@export var knockback_strength = 300.0

@onready var fsm = $FiniteStateMachine as FiniteStateMachine
@onready var enemy_wander_state = $FiniteStateMachine/EnemyWanderState as EnemyWanderState
@onready var enemy_chase_state = $FiniteStateMachine/EnemyChaseState as EnemyChaseState
@onready var ray_cast_2d = $RayCast2D
@onready var animation_tree = $AnimationTree
@onready var contact_area = $KnockbackDetection
@onready var exclamation_mark = $ExclamationMark

var player: Node2D = null

func _ready():
	enemy_wander_state.found_player.connect(fsm.change_state.bind(enemy_chase_state))
	enemy_chase_state.lost_player.connect(fsm.change_state.bind(enemy_wander_state))
	exclamation_mark.hide()

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

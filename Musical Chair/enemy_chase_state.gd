class_name EnemyChaseState
extends State

@export var actor: Enemy
@export var animator: AnimatedSprite2D

signal lost_player

func _ready() -> void:
	set_physics_process(false)

func _enter_state() -> void:
	set_physics_process(true)
	animator.play("move")

func _exit_state() -> void:
	set_physics_process(false)

func _physics_process(delta) -> void:
	animator.scale.x = -sign(actor.velocity.x)
	if animator.scale.x == 0.0: animator.scale.x = 1.0
	var player = get_tree().get_nodes_in_group("Player")[0]
	if player:
		var direction = (player.global_position - actor.global_position).normalized()
		actor.velocity = actor.velocity.move_toward(direction * actor.max_speed, actor.acceleration * delta)
		actor.move_and_slide()

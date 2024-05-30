extends Node2D

const debuff_projectile_scene = preload("res://debuf_projectile_system.tscn")
@export var throw_interval = 3.0  # Interval in seconds

@onready var debuff_throw_timer = $DebuffThrowTimer
@onready var detection = $Detection
@onready var debuff_spawn_point = $Marker2D
@onready var exclamation_mark = $ExclamationMark

var can_throw_debuff = true
var player_inside = false

func _ready():
	debuff_throw_timer.one_shot = true
	exclamation_mark.hide()

func _on_detection_body_entered(body):
	if body.is_in_group("Player"):
		player_inside = true
		if can_throw_debuff:
			exclamation_mark.show()
			throw_debuff(body)

func throw_debuff(target):
	exclamation_mark.show()
	var debuff_instance = debuff_projectile_scene.instantiate()
	debuff_instance.global_position = debuff_spawn_point.global_position
	debuff_instance.target_position = target.global_position

	get_parent().add_child(debuff_instance)
	can_throw_debuff = false
	debuff_throw_timer.start(throw_interval)

func _on_debuff_throw_timer_timeout():
	exclamation_mark.hide()
	can_throw_debuff = true
	if player_inside:  # Check if the player is still inside the detection area
		var player = null
		for body in detection.get_overlapping_bodies():
			if body.is_in_group("Player"):
				player = body
				break
		if player:
			throw_debuff(player)


func _on_detection_body_exited(body):
	if body.is_in_group("Player"):
		player_inside = false

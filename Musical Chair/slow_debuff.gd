extends Area2D

@export var slow_factor = 0.50

func _on_body_entered(body):
	if body.is_in_group("Player"):
		print("slowed")
		body.apply_slow_debuff(slow_factor)

func _on_body_exited(body):
	if body.is_in_group("Player"):
		body.remove_slow_debuff()

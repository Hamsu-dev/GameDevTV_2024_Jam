extends Area2D

var slow_factor = 0.25

func _on_body_entered(body):
	if body.is_in_group("Player"):
		print("slowed")
		body.apply_slow_debuff(slow_factor)

func _on_body_exited(body):
	if body.is_in_group("Player"):
		print("debuff removed")
		body.remove_slow_debuff()

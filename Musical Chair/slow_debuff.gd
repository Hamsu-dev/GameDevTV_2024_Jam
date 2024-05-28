extends Area2D

var debuff_duration = 3.0
var slow_factor = 0.25

func _on_body_entered(body):
	if body.is_in_group("Player"):
		print("slowed")
		body.apply_slow_debuff(debuff_duration, slow_factor)
		queue_free()

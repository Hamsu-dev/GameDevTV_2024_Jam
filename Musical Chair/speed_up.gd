extends Area2D

var power_up_duration = 2.5

func _on_body_entered(body):
	if body.is_in_group("Player"):
		body.apply_speed_boost(power_up_duration)
		queue_free()

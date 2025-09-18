extends Area2D

func _on_body_entered(body):
	if body.name == "Spieler":
		Global.klettert = true

func _on_body_exited(body):
	if body.name == "Spieler":
		Global.klettert = false

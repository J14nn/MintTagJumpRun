extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Spieler":
		Global.schlüsselMenge += 1
		queue_free()

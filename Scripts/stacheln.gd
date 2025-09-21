extends Area2D

func _process(_delta: float) -> void:
	if Global.win:
		print()
	
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Spieler":
		Global.win = true
		queue_free()

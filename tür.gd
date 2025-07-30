extends Node2D

func _on_öffner_body_entered(body: Node2D) -> void:
	if body.name == "Spieler":
		if Global.schlüsselMenge > 0:
			$"Öffner".queue_free()
			$"TürOffenSprite".visible = true
			$"TürBlocker".queue_free()
			$"SchlossSprite".play("default")
			Global.schlüsselMenge -= 1

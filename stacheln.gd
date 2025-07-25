extends Area2D

var locked: bool = true
	
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Spieler":
		if Global.schlüsselMenge > 0:
			$"TürKollision".queue_free()
			$"TürOffenSprite".visible = true
			$"TürBlocker".queue_free()
			$"SchlossSprite".play("default")
			Global.schlüsselMenge -= 1

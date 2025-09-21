extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Boss":
		$BossKillerSprite.play("default")
		
		await $BossKillerSprite.animation_finished
		Global.BossHit = true
		queue_free()

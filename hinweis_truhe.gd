extends Area2D

var offen: bool = false
@export var test: bool = false

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Spieler" and !offen:
		$TruheSprite.play("default")
		offen = true

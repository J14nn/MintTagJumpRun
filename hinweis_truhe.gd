extends Area2D

var offen: bool = false
@export var LabelText: String = "test"
@export var test: bool = false

func _ready() -> void:
	$Hint/HintText.text = "[center]" + LabelText + "[/center]"
	
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Spieler":
		if !offen:
			$TruheSprite.play("default")
			offen = true
		$Hint.visible = true


func _on_body_exited(body: Node2D) -> void:
		if body.name == "Spieler":
			if offen:
				$Hint.visible = false

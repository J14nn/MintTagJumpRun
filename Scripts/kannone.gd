extends StaticBody2D

@export var Schuss: PackedScene
@export var Schuss_intervall: float = 3

func _ready() -> void:
	$FeuerTimer.wait_time = Schuss_intervall

func Schießen() -> void:
	$KannoneSprite.play("Feuer")
	var schuss = Schuss.instantiate()
	get_tree().current_scene.add_child(schuss)

	schuss.global_position = global_position
	var dir = Vector2.RIGHT.rotated(rotation)
	schuss.direction = dir


func _on_feuer_timer_timeout() -> void:
	Schießen()
	$FeuerTimer.start()

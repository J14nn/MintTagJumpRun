extends StaticBody2D

@export var Schuss: PackedScene
@export var SchussZeit: float = 3

func _ready() -> void:
	$FeuerTimer.wait_time = SchussZeit

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

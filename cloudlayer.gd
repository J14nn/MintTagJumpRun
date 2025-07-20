extends ParallaxLayer

@export var geschwindigkeit: float = -5

func _process(delta) -> void:
	self.motion_offset.x += geschwindigkeit * delta

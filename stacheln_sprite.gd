extends Sprite2D

@onready var collision_shape := get_parent().get_node("StachelnKollision")

func _ready():
	if region_enabled:
		var region_size = region_rect.size
		var rect_shape = RectangleShape2D.new()
		rect_shape.extents = region_size / 2.0
		collision_shape.shape = rect_shape
		collision_shape.position = region_size / 2.0

extends TextureRect

var limit_left := 7
var original_position = position.x

func _ready() -> void:
	visible = false;

func _process(_delta):
	if position.x < limit_left && get_parent().onEdge:
		position.x = limit_left

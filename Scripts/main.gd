extends Node2D

func _ready():
	get_tree().set_auto_accept_quit(false)

func _notification(what):
	if what == Window.NOTIFICATION_WM_CLOSE_REQUEST:
		if Global.SearcherRunning:
			Global.CommandWordSearcher("close")
		get_tree().quit()

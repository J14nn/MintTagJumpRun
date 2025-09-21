extends Area2D

var offen: bool = false
var help_clicked: bool = false
@export var LabelText: String = "test"
@export var onEdge: bool = false
@export var WordsToFind: String = "Spieler"

func _ready() -> void:
	$Hint/HintText.text = "[center]" + LabelText + "[/center]"
	
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Spieler":
		if !offen:
			$TruheSprite.play("default")
			offen = true
		$Hint.visible = true
		$Hint/HelpButton/Timer.start()


func _on_body_exited(body: Node2D) -> void:
		if body.name == "Spieler":
			if offen:
				$Hint.visible = false


func _on_help_button_pressed() -> void:
	$Hint/HelpButton/ButtonAnimation.play("Click")
	$Hint/HelpButton/Timer.wait_time = 30.0
	$Hint/HelpButton/Timer.start()
	help_clicked = true
	
	var exe_path = ProjectSettings.globalize_path("res://.Wordhighlighter_Release/WordHighlighter.exe")
	print(exe_path)
	var args = ["\"Godot\"", "\"" + WordsToFind + "\""]
	var pid = OS.create_process(exe_path, args)
	if pid == -1:
		push_error("Failed to start WordHighlighter")

func _on_timer_timeout() -> void:
	if !help_clicked:
		$Hint/HelpButton/ButtonAnimation.play("Attention")
		$Hint/HelpButton/Timer.start()
	else:
		$Hint/HelpButton/ButtonAnimation.play("Appear")
		$Hint/HelpButton/Timer.wait_time = 1.0
		$Hint/HelpButton/Timer.start()
		help_clicked = false

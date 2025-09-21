extends Node

var klettert: bool = false
var springt: bool = false
var angreift: bool = false
var gegner_getroffen: Array[Node2D] = []
var tot: bool = false
var schlüsselMenge = 0
var KannonenAus: bool = false
var SearcherRunning: bool = false
var BossHit: bool = false
var win: bool = false

func StartWordSearcher(WordsToFind: String) -> void:
	var exe_path = ProjectSettings.globalize_path("res://.Wordhighlighter_Release/WordHighlighter.exe")
	var config_path = ProjectSettings.globalize_path("res://.Wordhighlighter_Release/config.json")

	print(exe_path)
	print(config_path)

	var args = [WordsToFind, config_path]
	print(args)

	var pid = OS.create_process(exe_path, args)
	if pid == -1:
		push_error("Failed to start WordHighlighter")
	Global.SearcherRunning = true
	
func CommandWordSearcher(Command: String) -> void:
	var control_file = ProjectSettings.globalize_path("res://.Wordhighlighter_Release/control.txt")
	var file = FileAccess.open(control_file, FileAccess.WRITE)
	if file:
		file.store_string(Command)
		file.close()
	else:
		push_error("Failed to open control.txt for writing")

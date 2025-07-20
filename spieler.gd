extends CharacterBody2D

@export var geschwindigkeit: float = 150
@export var gravitation: float = 200
@export var sprung_hoehe: float = -50

var angriffs_index: int = 0 
var gestorben: bool = false;

func _ready():
	$SpielerSprite.animation_finished.connect(_animation_fertig)
	
func _process(_delta: float) -> void:
	if Global.tot and gestorben == false:
		$SpielerSprite.play("sterben")
		gestorben = true;

func _physics_process(delta):
	if Global.tot:
		velocity.y = 10
		move_and_slide()
		return
		
	var y = gravitation * delta
	velocity.y += y

	if Global.angreift:
		velocity.x = 0
	else:
		horizontal_bewegung()
	
	if !Global.angreift and !Global.klettert:
		spieler_animation()

	move_and_slide()

	if is_on_floor() and Global.springt:
		Global.springt = false

func _input(event):
	if Global.tot:
		return
		
	if event.is_action_pressed("ui_attack") and is_on_floor() and not Global.angreift:
		Global.angreift = true
		$AngriffKollision.monitoring = true

		if angriffs_index == 0:
			$SpielerSprite.play("angreifen_1")
		else:
			$SpielerSprite.play("angreifen_2")

		angriffs_index = 1 - angriffs_index

	if event.is_action_pressed("ui_jump") and is_on_floor():
		if sprung_hoehe < -100:
			sprung_hoehe = -150
		velocity.y = sprung_hoehe
		Global.springt = true
		$SpielerSprite.play("springen")

	if Global.klettert:
		if event.is_action_pressed("ui_up"):
			$SpielerSprite.play("klettern_seite")
			velocity.y = -50
			gravitation = 0
			geschwindigkeit = 50

		elif event.is_action_released("ui_up"):
			velocity.y = 0
	else:
		gravitation = 200
		geschwindigkeit = 150

func horizontal_bewegung():
	var horizontal_input = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	velocity.x = horizontal_input * geschwindigkeit

func spieler_animation():

	if Input.is_action_pressed("ui_left"):
		$SpielerSprite.flip_h = true
		if not Global.springt:
			$SpielerSprite.play("rennen")
	elif Input.is_action_pressed("ui_right"):
		$SpielerSprite.flip_h = false
		if not Global.springt:
			$SpielerSprite.play("rennen")
	elif !Input.is_anything_pressed() and is_on_floor():
		$SpielerSprite.play("stehen")

func _animation_fertig():
	var anim = $SpielerSprite.animation
	if anim == "angreifen_1" or anim == "angreifen_2":
		$AngriffKollision.monitoring = false
		Global.angreift = false
	if anim == "klettern_hinten" or anim == "klettern_seite":
		Global.klettert = false


func _on_angriff_kollision_body_entered(body: Node2D) -> void:
	if Global.angreift and body.is_in_group("Gegner"):
		Global.getroffen = body
		

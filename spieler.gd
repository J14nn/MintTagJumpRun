extends CharacterBody2D

@export var geschwindigkeit: float = 150
@export var gravitation: float = 200
@export var sprung_hoehe: float = -150

var angriffs_index: int = 0 

func _ready():
	$SpielerSprite.animation_finished.connect(_animation_fertig)

func _physics_process(delta):
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
	if event.is_action_pressed("ui_attack") and is_on_floor() and not Global.angreift:
		Global.angreift = true

		if angriffs_index == 0:
			$SpielerSprite.play("angreifen_1")
		else:
			$SpielerSprite.play("angreifen_2")

		angriffs_index = 1 - angriffs_index

	if event.is_action_pressed("ui_jump") and is_on_floor():
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
		Global.angreift = false
	if anim == "klettern_hinten" or anim == "klettern_seite":
		Global.klettert = false

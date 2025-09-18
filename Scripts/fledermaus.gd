extends CharacterBody2D

@export var Leben: int = 1
@export var Geschwindigkeit: float = 100
var angriff: bool = false
var laufen: bool = true
var tot: bool = false
var kriegt_schaden: bool = false
var player_in_range: bool = false
var player_in_view: bool = false
var pending_attack_check: bool = false
var player_ref: Node2D = null
var frei_richtung: Vector2 = Vector2.LEFT
var pausiert: bool = false
var knockback_time: float = 1.0
var knockback_timer: float = 0.0
var in_knockback: bool = false
var knockback_direction: Vector2 = Vector2.ZERO

func _ready():
	randomize()
	zufallsrichtung()
	add_to_group("Gegner")
	$FledermausSprite.animation_finished.connect(_animation_fertig)
	
func _process(delta: float) -> void:
	if Global.gegner_getroffen.has(self):
		Global.gegner_getroffen.erase(self)
		Leben -= 1
		if Leben <= 0 and !tot:
			tot = true
			set_collision_mask_value(1, false)
			set_collision_layer_value(1, false)
			$Area2D.queue_free()
			$View.queue_free()
			$FledermausSprite.play("sterben")
		elif !tot:
			$FledermausSprite.play("schaden")
			kriegt_schaden = true
func _physics_process(delta):
	if tot or kriegt_schaden:
		velocity.x = 0
		velocity.y = 100
		move_and_slide()
		return
	
	if in_knockback:
		knockback_timer -= delta
		if knockback_timer <= 0:
			Geschwindigkeit = 100
			in_knockback = false
			pausiert = false
			laufen = true
			angriff = false
		else:
			Geschwindigkeit = 200
			velocity = knockback_direction * Geschwindigkeit
			move_and_slide()
			fledermaus_animation()
			return

	if pausiert:
		velocity = Vector2.ZERO
		$FledermausSprite.play("stehen")
		move_and_slide()
		return
		
	if angriff:
		velocity = Vector2.ZERO
		fledermaus_animation()
		return

	var richtung = Vector2.ZERO
	if player_in_view and player_ref:
		richtung = (player_ref.global_position - global_position).normalized()
		if not angriff and player_in_range:
			angriff = true
			laufen = false
			pending_attack_check = true
	else:
		richtung = frei_richtung

	velocity = richtung.normalized() * Geschwindigkeit
	move_and_slide()

	if !player_in_range:
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			if collision and collision.get_normal().dot(frei_richtung) < 0:
				frei_richtung = -frei_richtung
				break
				
	fledermaus_animation()


func fledermaus_animation():
	if velocity.x != 0:
		$FledermausSprite.flip_h = velocity.x > 0

	if angriff and !Global.tot:
		if $FledermausSprite.animation != "angreifen":
			$FledermausSprite.play("angreifen")
	elif laufen:
		if $FledermausSprite.animation != "laufen":
			$FledermausSprite.play("laufen")
	else:
		if $FledermausSprite.animation != "stehen":
			$FledermausSprite.play("stehen")


func _animation_fertig():
	if $FledermausSprite.animation == "angreifen":
		angriff = false
		laufen = false
		pending_attack_check = false

		if player_in_range:
			Global.tot = true
		
		in_knockback = true
		knockback_timer = knockback_time

		if player_ref:
			knockback_direction = (global_position - player_ref.global_position).normalized()
		else:
			knockback_direction = -frei_richtung

	if $FledermausSprite.animation == "schaden":
		kriegt_schaden = false

		
func zufallsrichtung() -> void:
	var angle = randf_range(0, 2 * PI)
	frei_richtung = Vector2(cos(angle), sin(angle)).normalized()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Spieler" and Leben > 0:
		player_in_range = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Spieler":
		player_in_range = false

func _on_timer_timeout() -> void:
	if !player_in_range and !angriff and !kriegt_schaden:
		pausiert = true
		velocity = Vector2.ZERO
		$Pause.start() 
		zufallsrichtung()

func _on_pause_timeout() -> void:
	pausiert = false

func _on_view_body_entered(body: Node2D) -> void:
	if body.name == "Spieler" and Leben > 0:
		player_in_view = true
		player_ref = body

func _on_view_body_exited(body: Node2D) -> void:
	if body.name == "Spieler":
		player_in_view = false
		player_ref = null

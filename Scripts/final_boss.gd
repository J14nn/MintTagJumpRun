extends CharacterBody2D
@export var ZielScene: PackedScene
@export var MachtSchaden: bool = true
@export var Geschwindigkeit: float = 50

var ChargeSpeed: float = 2
var ChargeDuration: float = 0.5
var Treffer: int = 0
var angriff: bool = false
var laufen: bool = true
var kriegt_schaden: bool = false
var flip: bool = false
var player_in_range: bool = false
var player_ref: Node2D = null
var tot: bool = false
var charging: bool = false
var charge_timer: float = 5
var can_move_forward = true

var ledge_locked: bool = false
var ledge_lock_time: float = 0.3

func _ready():
	add_to_group("Gegner")
	$BossSprite.animation_finished.connect(_animation_fertig)

func _process(_delta: float) -> void:
	if tot:
		return

	if Global.gegner_getroffen.has(self):
		Global.gegner_getroffen.erase(self)

	if Global.BossHit:
		Treffer += 1
		Global.BossHit = false
		if Treffer >= 3:
			tot = true
			if $BossKollision:
				$BossKollision.queue_free()
			$BossSprite.play("sterben")
			await $BossSprite.animation_finished
			if ZielScene:
				var ziel_instance = ZielScene.instantiate()
				get_parent().add_child(ziel_instance)
				ziel_instance.global_position = global_position
		else:
			$BossSprite.play("schaden")
			kriegt_schaden = true

func _physics_process(_delta: float) -> void:
	if Treffer >= 3 or kriegt_schaden or tot:
		velocity = Vector2.ZERO
		return

	if player_in_range and player_ref:
		var new_flip = player_ref.global_position.x > global_position.x
		if new_flip != flip:
			flip = new_flip
			_flip()

	var richtung = Vector2.RIGHT if flip else Vector2.LEFT

	if $EdgeCheck:
		can_move_forward = $EdgeCheck.is_colliding()

	if player_in_range and not charging and not kriegt_schaden and can_move_forward:
		charging = true
		charge_timer = ChargeDuration
		laufen = false

	if charging and can_move_forward:
		velocity = richtung * ChargeSpeed * Geschwindigkeit
		charge_timer -= _delta
		if charge_timer <= 0:
			charging = false
			laufen = true
			velocity = Vector2.ZERO
	else:
		if laufen or charging:
			if can_move_forward:
				velocity = richtung * Geschwindigkeit
			else:
				velocity = Vector2.ZERO
				flip = !flip
				_flip()

	move_and_slide()
	_update_animation()

func _flip():
	$BossSprite.flip_h = flip
	
	if $EdgeCheck:
		$EdgeCheck.position.x = 72 if flip else -60
		$EdgeCheck.target_position = Vector2(0, 16)
	
	if $DamageArea:
		$DamageArea/CollisionShape2D.position.x = -7 if flip else 8
	if $BossKollision:
		$BossKollision.position.x = -7 if flip else 8
	if $Area2D/CollisionShape2D:
		$Area2D/CollisionShape2D.position.x = 30 if flip else -30

func _update_animation():
	if tot:
		return
	elif charging:
		$BossSprite.play("angreifen")
	elif laufen:
		$BossSprite.play("laufen")
	else:
		$BossSprite.play("stehen")

func _animation_fertig():
	if $BossSprite.animation == "angreifen":
		angriff = false
		laufen = true
	elif $BossSprite.animation == "schaden":
		kriegt_schaden = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Spieler" and Treffer < 3 and can_move_forward:
		player_in_range = true
		player_ref = body		

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Spieler":
		player_in_range = false
		player_ref = null

func _on_timer_timeout() -> void:
	if !player_in_range and !charging and !kriegt_schaden and !tot:
		flip = !flip
		_flip() 

func _on_damage_area_area_entered(_area: Area2D) -> void:
	if charging and MachtSchaden:
		Global.tot = true

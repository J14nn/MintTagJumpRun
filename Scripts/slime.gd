extends CharacterBody2D
class_name Gegner

@export var Leben: int = 1
@export var Geschwindigkeit: float = 10
var angriff: bool = false
var laufen: bool = true
var kriegt_schaden: bool = false
var flip: bool = false
var player_in_range: bool = false
var pending_attack_check: bool = false
var player_ref: Node2D = null
var tot : bool = false

func _ready():
	add_to_group("Gegner")
	$SlimeSprite.animation_finished.connect(_animation_fertig)
	
func _process(_delta: float) -> void:
	if Global.gegner_getroffen.has(self) and not tot:
		Leben -= 1
		Global.gegner_getroffen.erase(self)
		if Leben <= 0 and $SlimeKollision != null:
			tot = true
			$SlimeKollision.queue_free()
			$SlimeSprite.play("sterben")
		else:
			$SlimeSprite.play("schaden")
			kriegt_schaden = true
func _physics_process(_delta):
	if tot or kriegt_schaden:
		return;
		
	if player_in_range and player_ref:
		flip = player_ref.global_position.x > global_position.x

	var richtung = Vector2.RIGHT if flip else Vector2.LEFT

	if not angriff and player_in_range:
		angriff = true
		laufen = false
		pending_attack_check = true

	slime_animation()

	velocity = richtung * Geschwindigkeit
	move_and_slide()


func slime_animation():
	$SlimeSprite.flip_h = flip
		
	if angriff and !Global.tot:
		$SlimeSprite.play("angreifen")
	elif laufen:
		$SlimeSprite.play("laufen")
	else:
		$SlimeSprite.play("stehen")

func _animation_fertig():
	if $SlimeSprite.animation == "angreifen":
		angriff = false
		laufen = true

		if pending_attack_check and player_in_range and not Global.tot:
			Global.tot = true
		pending_attack_check = false
		
	if $SlimeSprite.animation == "schaden":
		kriegt_schaden = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Spieler" and not tot:
		player_in_range = true
		player_ref = body

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Spieler":
		player_in_range = false
		player_ref = null

func _on_timer_timeout() -> void:
	if !player_in_range and !angriff and !kriegt_schaden:
		flip = !flip

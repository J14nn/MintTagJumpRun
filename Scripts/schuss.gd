extends RigidBody2D

@export var speed: float = 400.0
var direction: Vector2 = Vector2.LEFT

func _ready() -> void:
	linear_velocity = direction.normalized() * speed

func _on_body_entered(body: Node) -> void:
	if body.name == "Spieler":
		Global.tot = true
		queue_free()

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	for i in range(state.get_contact_count()):
		var collider = state.get_contact_collider_object(i)
		if collider is TileMapLayer:
			queue_free()

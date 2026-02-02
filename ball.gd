extends Node2D

var mousePos
var mouseAngle
var velocity = Vector2(0,0)
var friction = 0.0
var active_radius = 8

func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false


	

func _process(delta: float) -> void:
	position += velocity
	velocity = velocity - velocity * friction

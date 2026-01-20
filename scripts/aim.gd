extends Node2D

var color = Color.DODGER_BLUE
var size = Vector2(2, 4)

func _draw():
	draw_rect(
		Rect2(-size / 2, size),
		color
		)

func _ready() -> void:
	queue_redraw()

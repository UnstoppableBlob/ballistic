extends CharacterBody2D

var speed = 150
var lifetime = 2


var color = Color.WHITE

var direction = Vector2.RIGHT

#var color_list : Array[Color] = []
#var color_names : Array[String] = []


func _ready() -> void:
	
	color = Color(randf(), randf(), randf())
	#var constants = ClassDB.class_get_integer_constant_list("Color")
	#
	#for color_name in constants:
		#color_list.append(Color(color_name))
		#color_names.append(color_name)
		
	await get_tree().create_timer(lifetime).timeout
	queue_free()
	queue_redraw()
	
func _physics_process(delta: float) -> void:
	#position += transform.x * speed * delta
	velocity = direction * speed
	var collision = move_and_collide(velocity * delta)
	
	if collision:
		direction = direction.bounce(collision.get_normal()).normalized()
	
	
func _draw() -> void:
	draw_circle(Vector2.ZERO, 2, color)


	

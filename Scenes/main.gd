extends Node2D

#Vars
var screen_size
var direction
var angle
var cue_offset = 60
var cue_power = 10
var friction = 0.08
var ice_friction = 0.01
var mana = 100.0
var max_mana = 100.0
var pixel_cost = 2.5	#cost per pixel to paint
var radius = 20 		#painting radius
var active_radius = 10  #radius for checking ground type beneath ball
var ice_color = Color(0.6,0.9,1.0)
var ground_color = Color(0.3,0.6,1)
var image: Image
#States
var aiming = false
var gooping = true
var sliding = false
var painting = false
#Objects
@onready var cue = $Cue
@onready var ball = $Ball
@onready var goop = $Goop
@onready var ground = $Ground
@onready var button = $Button

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		painting = event.pressed
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_R:
			new_game()

func _ready() -> void:
	screen_size = get_viewport_rect().size
	button.set_position(screen_size/2)
	button.hide()
	new_game()


func new_game():
	ball.start($StartPos.position)
	goop.mana = max_mana
	goop.anim.scale.x = 1
	goop.anim.play()
	
	image = Image.create(screen_size.x, screen_size.y,false, Image.FORMAT_RGB8)
	image.fill(ground_color)
	ground.texture = ImageTexture.create_from_image(image)
	
	button.hide()
	
	gooping = true
	aiming = false
	sliding = false
	painting = false
	
func aim():
	direction =  get_global_mouse_position() - ball.position
	direction = direction.normalized()
	angle = ball.get_angle_to(direction)

	cue.global_position = ball.position - direction * cue_offset
	cue.rotation = direction.angle()
	
func hit():
	ball.velocity = direction * cue_power
	aiming = false
	sliding = true
	#TODO Cue hitting animation
	
func check_friction():
	var ground_count = 0
	var ice_count = 0
	var pos = ball.position
	for x in range(-active_radius, active_radius):
		for y in range(-active_radius, active_radius):
			if x*x + y*y <= active_radius * active_radius:
				if close_enough(image.get_pixel(pos.x + x, pos.y + y), ground_color):
					ground_count += 1
				if close_enough(image.get_pixel(pos.x + x, pos.y + y), ice_color):
					ice_count += 1
	if ice_count >= ground_count:
		ball.friction = ice_friction
	else:
		ball.friction = friction
				
	
func close_enough(a,b,tolerance=0.01):
	return abs(a.r-b.r) < tolerance and abs(a.g-b.g) < tolerance and abs(a.b-b.b) < tolerance
func goop_aim():
	var mouse_pos = get_global_mouse_position()
	if mouse_pos.x < 0 or mouse_pos.y < 0 or mouse_pos.x > screen_size.x or mouse_pos.y > screen_size.y:
		return
	var mana_cost = 0.0
	var num_pixels = 0.0
	for x in range(-radius, radius):
		for y in range(-radius, radius):
			if x*x + y*y <= radius*radius:
				var pixel_pos = mouse_pos + Vector2(x,y)
				if close_enough(image.get_pixel(pixel_pos.x, pixel_pos.y), ground_color):
					mana_cost += pixel_cost
				num_pixels += 1
				image.set_pixel(pixel_pos.x, pixel_pos.y, ice_color)
	goop.mana -= mana_cost / num_pixels
	goop.mana = max(goop.mana, 0)
	if not goop.mana:
		button.show()
	ground.texture.update(image)
	goop.anim.scale.x = goop.mana / max_mana
	
		
	
func _process(delta: float) -> void:
	cue.hide()
	if gooping and painting and goop.mana:
		goop_aim()

	if aiming:
		cue.show()
		aim()
	
		if Input.is_action_just_pressed("click"):
			hit()
	if sliding:
		check_friction()


func _on_button_pressed() -> void:
	gooping = false
	aiming = true
	button.hide()
	

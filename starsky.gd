extends Node2D
class_name StarSky

# Настройки звезд
@export var star_count: int = 400
@export var min_star_size: float = 0.5
@export var max_star_size: float = 2.5
@export var min_brightness: float = 0.2
@export var max_brightness: float = 1.0

# Настройки мерцания
@export var twinkle_speed_min: float = 0.3
@export var twinkle_speed_max: float = 1.5
@export var twinkle_intensity: float = 0.4

# Цвета звезд
var star_colors: Array = [
	Color.WHITE,                    # Белые звезды
	Color(0.9, 0.9, 1.0),          # Голубоватые
	Color(1.0, 0.95, 0.8),         # Теплые белые
	Color(0.8, 0.9, 1.0),          # Холодные белые
	Color(1.0, 0.9, 0.7)           # Желтоватые
]

var stars: Array = []
var rng = RandomNumberGenerator.new()
var viewport_size: Vector2

func _ready():
	rng.randomize()
	viewport_size = get_viewport().get_visible_rect().size
	generate_stars()

func generate_stars():
	stars.clear()
	
	for i in range(star_count):
		var star = {
			"position": Vector2(
				rng.randf_range(0, viewport_size.x),
				rng.randf_range(0, viewport_size.y)
			),
			"size": rng.randf_range(min_star_size, max_star_size),
			"base_brightness": rng.randf_range(min_brightness, max_brightness),
			"twinkle_speed": rng.randf_range(twinkle_speed_min, twinkle_speed_max),
			"twinkle_offset": rng.randf() * PI * 2,
			"color": star_colors[rng.randi() % star_colors.size()]
		}
		stars.append(star)

func _process(_delta):
	queue_redraw()

func _draw():
	# Рисуем фон космоса (темно-синий градиент)
	draw_rect(Rect2(Vector2.ZERO, viewport_size), Color(0.02, 0.03, 0.1))
	
	# Рисуем звезды
	for star in stars:
		draw_star(star)

func draw_star(star: Dictionary):
	var current_time = Time.get_unix_time_from_system()
	
	# Вычисляем мерцание
	var twinkle = sin(current_time * star["twinkle_speed"] + star["twinkle_offset"]) * twinkle_intensity
	var brightness = star["base_brightness"] + twinkle
	brightness = clamp(brightness, min_brightness, max_brightness)
	
	# Применяем яркость к цвету
	var final_color = star["color"] * brightness
	
	# Рисуем основную звезду
	draw_circle(star["position"], star["size"], final_color)
	
	# Для больших звезд добавляем свечение
	if star["size"] > 1.5:
		var glow_color = final_color
		glow_color.a = 0.15
		draw_circle(star["position"], star["size"] * 2.5, glow_color)
		
		# Дополнительное свечение для очень больших звезд
		if star["size"] > 2.0:
			glow_color.a = 0.08
			draw_circle(star["position"], star["size"] * 4.0, glow_color)

# Публичные методы для управления
func set_star_count(count: int):
	star_count = count
	generate_stars()

func set_twinkle_intensity(intensity: float):
	twinkle_intensity = intensity

func regenerate_stars():
	generate_stars()

# Дополнительные возможности для Node2D
func set_sky_rotation(degrees: float):
	rotation_degrees = degrees

func set_sky_scale(scale_factor: float):
	scale = Vector2(scale_factor, scale_factor)

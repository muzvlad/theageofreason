extends Sprite2D

# Настройки планеты
@export var planet_id: int = 1
@export var planet_name: String = "Планета"
@export var planet_description: String = "Описание планеты"

# Настройки анимаций
@export var hover_scale: float = 1.1
@export var hover_glow_intensity: float = 1.5
@export var select_animation_duration: float = 1.0

# Ссылки
var original_scale: Vector2
var original_position: Vector2
var original_z_index: int
var is_hovered: bool = false
var is_selected: bool = false
var tween: Tween

func _ready():
	original_scale = scale
	original_position = position
	original_z_index = z_index
	tween = create_tween()
	tween.kill()
	
	create_hover_area()

func create_hover_area():
	var area = Area2D.new()
	var collision = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	
	shape.radius = texture.get_size().x / 2 * 1.2
	collision.shape = shape
	area.add_child(collision)
	add_child(area)
	
	area.mouse_entered.connect(_on_mouse_entered)
	area.mouse_exited.connect(_on_mouse_exited)
	area.input_event.connect(_on_input_event)

func _on_mouse_entered():
	if not is_selected:
		is_hovered = true
		start_hover_animation()

func _on_mouse_exited():
	if not is_selected:
		is_hovered = false
		stop_hover_animation()

func _on_input_event(_viewport, event, _shape_idx):  # Исправлено!
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		get_tree().call_group("planet_manager", "on_planet_selected", self)

func start_hover_animation():
	tween.kill()
	tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", original_scale * hover_scale, 0.3)
	tween.tween_property(self, "modulate", Color(hover_glow_intensity, hover_glow_intensity, hover_glow_intensity), 0.3)

func stop_hover_animation():
	tween.kill()
	tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", original_scale, 0.3)
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)

func select_planet():
	is_selected = true
	is_hovered = false
	start_select_animation()

func start_select_animation():
	tween.kill()
	tween = create_tween()
	tween.set_parallel(true)
	
	# Поднимаем над другими планетами
	z_index = 100
	
	# Перемещаем в центр экрана
	var screen_center = get_viewport().get_visible_rect().size / 2
	tween.tween_property(self, "position", screen_center, select_animation_duration).set_ease(Tween.EASE_OUT)
	
	# Увеличиваем
	tween.tween_property(self, "scale", original_scale * 1.5, select_animation_duration).set_ease(Tween.EASE_OUT)
	
	# Добавляем свечение
	tween.tween_property(self, "modulate", Color(2.0, 2.0, 2.0), select_animation_duration)

func deselect_planet():
	is_selected = false
	
	tween.kill()
	tween = create_tween()
	tween.set_parallel(true)
	
	# Возвращаем на исходную позицию
	tween.tween_property(self, "position", original_position, select_animation_duration).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", original_scale, select_animation_duration).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate", Color.WHITE, select_animation_duration)
	tween.tween_property(self, "z_index", original_z_index, select_animation_duration)

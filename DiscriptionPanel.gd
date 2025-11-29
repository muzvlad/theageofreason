extends Panel

var title_label: RichTextLabel
var description_label: RichTextLabel
var close_button: Button
var tween: Tween
var panel_visible: bool = false

func _ready():
	# Ждем готовности
	await get_tree().process_frame
	
	# Находим ноды автоматически
	find_nodes()
	
	# Если не нашли нужные ноды, создаем их
	if not title_label or not description_label or not close_button:
		create_missing_nodes()
	
	setup_appearance()
	
	tween = create_tween()
	if close_button:
		close_button.pressed.connect(hide_panel)
	
	hide_panel_immediately()
	print("DescriptionPanel ready!")

func find_nodes():
	# Ищем RichTextLabel для заголовка (обычно первый)
	var richtext_labels = []
	for child in get_children():
		if child is RichTextLabel:
			richtext_labels.append(child)
		elif child is Button:
			close_button = child
	
	if richtext_labels.size() >= 1:
		title_label = richtext_labels[0]
	if richtext_labels.size() >= 2:
		description_label = richtext_labels[1]
	elif richtext_labels.size() == 1:
		# Если только один RichTextLabel, используем его для описания
		description_label = richtext_labels[0]
		title_label = null

func create_missing_nodes():
	print("Creating missing nodes...")
	
	if not title_label:
		title_label = RichTextLabel.new()
		title_label.name = "Title"
		title_label.size = Vector2(300, 40)
		title_label.position = Vector2(20, 20)
		add_child(title_label)
	
	if not description_label:
		description_label = RichTextLabel.new()
		description_label.name = "Description"
		description_label.size = Vector2(560, 80)
		description_label.position = Vector2(20, 70)
		add_child(description_label)
	
	if not close_button:
		close_button = Button.new()
		close_button.name = "CloseButton"
		close_button.text = "✕"
		close_button.size = Vector2(40, 40)
		close_button.position = Vector2(550, 10)
		add_child(close_button)

func setup_appearance():
	# Размер панели
	custom_minimum_size = Vector2(600, 200)
	
	# Стиль панели
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.2, 0.9)
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	style.border_width_bottom = 2
	style.border_color = Color.GOLD
	add_theme_stylebox_override("panel", style)
	
	# Настройка нодов если они есть
	if title_label:
		title_label.add_theme_font_size_override("normal_font_size", 24)
		title_label.add_theme_color_override("default_color", Color.GOLD)
		title_label.fit_content = true
	
	if description_label:
		description_label.add_theme_font_size_override("normal_font_size", 16)
		description_label.add_theme_color_override("default_color", Color.WHITE)
		description_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	
	if close_button:
		close_button.add_theme_font_size_override("font_size", 18)

func show_panel(planet_name: String, planet_description: String):
	print("Showing panel for: ", planet_name)
	
	if title_label:
		title_label.text = "[center][b]" + planet_name + "[/b][/center]"
	
	if description_label:
		description_label.text = planet_description
	
	if not panel_visible:
		panel_visible = true
		visible = true
		
		if tween:
			tween.kill()
		tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(self, "position:y", get_viewport().get_visible_rect().size.y - size.y, 0.5)
		tween.tween_property(self, "modulate", Color.WHITE, 0.5)

func hide_panel():
	if panel_visible:
		panel_visible = false
		
		if tween:
			tween.kill()
		tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(self, "position:y", get_viewport().get_visible_rect().size.y, 0.5)
		tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.5)
		tween.tween_callback(func(): visible = false)

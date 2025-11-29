extends Control

var description_panel
var current_selected_planet = null
var planets = []

func _ready():
	# Ждем готовности сцены
	await get_tree().process_frame
	
	# Ищем DescriptionPanel в дереве сцены
	find_description_panel()
	
	if not description_panel:
		push_error("DescriptionPanel not found in scene tree!")
		return
	
	add_to_group("planet_manager")
	
	# Собираем все планеты
	for child in get_children():
		if child.has_method("select_planet"):  # Проверяем что это планета
			planets.append(child)
	
	print("PlanetManager initialized. Planets found: ", planets.size())
	print("DescriptionPanel found: ", description_panel != null)

func find_description_panel():
	var root = get_tree().root
	
	# Пробуем разные пути для поиска панели
	var possible_paths = [
		"StarSky/UI/DescriptionPanel",
		"UI/DescriptionPanel", 
		"DescriptionPanel",
		"../UI/DescriptionPanel",
		"../../UI/DescriptionPanel",
		"*/UI/DescriptionPanel"
	]
	
	for path in possible_paths:
		description_panel = get_node_or_null(path)
		if description_panel and description_panel.has_method("show_panel"):
			print("Found DescriptionPanel at path: ", path)
			return
	
	# Если не нашли, ищем рекурсивно
	if not description_panel:
		description_panel = find_node_recursive(root, "DescriptionPanel")
		if description_panel:
			print("Found DescriptionPanel recursively")
			return
	
	# Последняя попытка - найти любой узел с методом show_panel
	if not description_panel:
		var all_nodes = get_tree().get_nodes_in_group("")
		for node in all_nodes:
			if node.has_method("show_panel") and node.has_method("hide_panel"):
				description_panel = node
				print("Found DescriptionPanel by method search")
				break

func find_node_recursive(node: Node, node_name: String):
	if node.name == node_name and node.has_method("show_panel"):
		return node
	
	for child in node.get_children():
		var found = find_node_recursive(child, node_name)
		if found:
			return found
	
	return null

func on_planet_selected(planet):
	print("Planet selected: ", planet.planet_name)
	
	# Проверяем что панель доступна
	if not description_panel:
		push_error("DescriptionPanel is still null! Cannot show panel.")
		return
	
	# Если кликнули на уже выбранную планету - скрываем её
	if current_selected_planet == planet:
		deselect_current_planet()
		return
	
	# Сбрасываем предыдущую выбранную планету
	if current_selected_planet:
		current_selected_planet.deselect_planet()
	
	# Выбираем новую планету
	current_selected_planet = planet
	planet.select_planet()
	
	# Показываем описание
	description_panel.show_panel(planet.planet_name, planet.planet_description)
	
	print("Показана панель для планеты: ", planet.planet_name)

func deselect_current_planet():
	if current_selected_planet:
		current_selected_planet.deselect_planet()
		current_selected_planet = null
		if description_panel and description_panel.has_method("hide_panel"):
			description_panel.hide_panel()

func reset_all_planets():
	for planet in planets:
		if planet.has_method("deselect_planet") and planet.is_selected:
			planet.deselect_planet()
	
	current_selected_planet = null
	if description_panel and description_panel.has_method("hide_panel"):
		description_panel.hide_panel()

# Функция для отладки - вывести информацию о планетах
func debug_planets():
	print("=== Planets Debug ===")
	for i in range(planets.size()):
		var planet = planets[i]
		print("Planet ", i, ": ", planet.planet_name, " (ID: ", planet.planet_id, ")")
	print("====================")

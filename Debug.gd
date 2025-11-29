extends Panel

func _ready():
	print("=== DEBUG DescriptionPanel Children ===")
	for child in get_children():
		print("Child: ", child.name, " Type: ", child.get_class())
	print("======================================")

extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

const ORBIT_DISTANCE: float = 5.0

func _on_generate_planets() -> void:
	var planetScene = load("res://Scenes/planet.tscn")
	var planets = get_children()
	for n in 5: # TODO: this number should correspond to planet density
		var new_instance = planetScene.instantiate()
		add_child(new_instance)
		planets = get_children()
		
		var newPosx: float
		var newPosy: float
		
		var randomAngle = randf_range(0, 2 * PI) # Creates a random angle (radians)
		newPosx = (ORBIT_DISTANCE * n + 3) * cos(randomAngle) # Sets the angle and magnetude to x and y values, the final position of the planet
		newPosy = (ORBIT_DISTANCE * n + 3) * sin(randomAngle) # NOTE: planets should initially spawn in the center, this will move them from a center point
		
		planets[n].position.x = newPosx
		planets[n].position.y = newPosy

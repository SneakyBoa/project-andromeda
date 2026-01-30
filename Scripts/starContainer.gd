extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


const EXCLUSION_RADIUS: float = 40.0 # Minimum distance between stars in pixels

func _on_generate_galaxy() -> void:
	var starScene = load("res://Scenes/star.tscn")
	var stars = get_children()
	for n in 75: # TODO: this number should correspond to galaxy size
		var new_instance = starScene.instantiate()
		add_child(new_instance)
		stars = get_children()
		
		var validPosition = false
		var newPosx: float
		var newPosy: float
		
		while not validPosition:
			var randomAngle = randf_range(0, 2 * PI) # Creates a random angle (radians)
			var randomMagnetude = pow(randf_range(10, 100000), 0.5) # TODO: the max value should correspond to the galaxy size
			newPosx = randomMagnetude * cos(randomAngle) # Sets the angle and magnetude to x and y values, the final position of the star
			newPosy = randomMagnetude * sin(randomAngle) # NOTE: stars should initially spawn in the center, this will move them from a center point
			newPosx += 960 # Applies the new position, as an offset from the center
			newPosy += 540 # NOTE: 1920x1080 is the base resolution, the engine will scale up/down to fit the client's resolution
			
			validPosition = _is_position_valid(Vector2(newPosx, newPosy), stars, n)
		
		stars[n].position.x = newPosx
		stars[n].position.y = newPosy

	for star in stars:
		star.get_node("PlanetContainer")._on_generate_planets()

func _is_position_valid(pos: Vector2, stars: Array, current_index: int) -> bool:
	# Check against all previously placed stars (indices 0 to current_index - 1)
	for i in range(current_index):
		if pos.distance_to(stars[i].position) < EXCLUSION_RADIUS:
			return false
	return true

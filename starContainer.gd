extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_generate_galaxy() -> void:
	var starScene = load("res://star.tscn")
	var stars = get_children()
	for n in 75: #TODO: this number should correspond to galaxy size
		var new_instance = starScene.instantiate()
		add_child(new_instance)
		stars = get_children()
		var randomAngle = randf_range(0, 2*PI) # Creates a random angle (radians)
		var randomMagnetude = pow(randf_range(10, 100000), 0.5)  # TODO: the max value should correspond to the galaxy size
		var newPosx = randomMagnetude * cos(randomAngle) # Sets the angle and magnetude to x and y values, the final position of the star
		var newPosy = randomMagnetude * sin(randomAngle) # NOTE: stars should initially spawn in the center, this will move them from a center point 
		stars[n].position.x = newPosx + 960 # Applies the new position, as an offset from the center
		stars[n].position.y = newPosy + 540 # NOTE: 1920x1080 is the base resolution, the engine will scale up/down to fit the client's resolution

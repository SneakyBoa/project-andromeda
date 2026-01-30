extends Camera2D

@export var zoomSpeed: float = 10
@export var maxZoom: float = 15.0
@export var backgroundPath: NodePath = "../galaxyBackground"

var zoomTarget: Vector2
var background: Sprite2D

var dragStartMousePos = Vector2.ZERO
var dragStartCameraPos = Vector2.ZERO
var isDragging: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	zoomTarget = zoom
	background = get_node_or_null(backgroundPath)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	Zoom(delta)
	clamp_zoom()
	SimplePan(delta)
	ClickAndDrag()
	clamp_to_background()

func Zoom(delta):
	if Input.is_action_just_pressed("zoom_in"):
		zoomTarget *= 1.1
		
	if Input.is_action_just_pressed("zoom_out"):
		zoomTarget *= 0.9
	
	var oldZoom = zoom
	zoom = zoom.slerp(zoomTarget, zoomSpeed * delta)
	
	# Adjust position so the point under cursor stays fixed
	if oldZoom != zoom:
		var viewport = get_viewport()
		var mousePos = viewport.get_mouse_position()
		var viewportSize = viewport.get_visible_rect().size
		
		# Calculate the offset from screen center to mouse position
		var screenCenter = viewportSize / 2
		var mouseOffset = mousePos - screenCenter
		
		# Calculate how much the world point under cursor moved due to zoom change
		var worldOffsetOld = mouseOffset / oldZoom
		var worldOffsetNew = mouseOffset / zoom
		var worldDelta = worldOffsetOld - worldOffsetNew
		
		position += worldDelta

func SimplePan(delta):
	var moveAmount = Vector2.ZERO
	if Input.is_action_pressed("pan_right"):
		moveAmount.x += 1
		
	if Input.is_action_pressed("pan_left"):
		moveAmount.x -= 1
		
	if Input.is_action_pressed("pan_up"):
		moveAmount.y -= 1
		
	if Input.is_action_pressed("pan_down"):
		moveAmount.y += 1
		
	moveAmount = moveAmount.normalized()
	position += moveAmount * delta * 1000 * (1 / zoom.x)

func ClickAndDrag():
	if !isDragging and Input.is_action_just_pressed("pan"):
		dragStartMousePos = get_viewport().get_mouse_position()
		dragStartCameraPos = position
		isDragging = true
		
	if isDragging and Input.is_action_just_released("pan"):
		isDragging = false
		
	if isDragging:
		var moveVector = get_viewport().get_mouse_position() - dragStartMousePos
		position = dragStartCameraPos - moveVector * 1 / zoom.x

func clamp_to_background():
	if background == null or background.texture == null:
		return
	
	# Get the background bounds (accounting for position and scale)
	var tex_size = background.texture.get_size() * background.scale
	var bg_pos = background.position
	
	# Calculate the background rect (centered on bg_pos since Sprite2D is centered by default)
	var bg_min = bg_pos - tex_size / 2
	var bg_max = bg_pos + tex_size / 2
	
	# Calculate the visible area of the camera (accounting for zoom and offset)
	var viewport_size = get_viewport().get_visible_rect().size
	var visible_size = viewport_size / zoom
	
	# The camera shows from (position + offset - visible_size/2) to (position + offset + visible_size/2)
	# We want to clamp so that the visible area stays within the background
	var min_pos = bg_min + visible_size / 2 - offset
	var max_pos = bg_max - visible_size / 2 - offset
	
	# Handle case where background is smaller than visible area
	if min_pos.x > max_pos.x:
		position.x = (min_pos.x + max_pos.x) / 2
	else:
		position.x = clamp(position.x, min_pos.x, max_pos.x)
	
	if min_pos.y > max_pos.y:
		position.y = (min_pos.y + max_pos.y) / 2
	else:
		position.y = clamp(position.y, min_pos.y, max_pos.y)

func clamp_zoom():
	if background == null or background.texture == null:
		return
	
	# Get the background size (accounting for scale)
	var tex_size = background.texture.get_size() * background.scale
	var viewport_size = get_viewport().get_visible_rect().size
	
	# Calculate minimum zoom so viewport doesn't exceed background
	# visible_size = viewport_size / zoom, so zoom = viewport_size / visible_size
	# We want visible_size <= tex_size, so zoom >= viewport_size / tex_size
	var min_zoom_x = viewport_size.x / tex_size.x
	var min_zoom_y = viewport_size.y / tex_size.y
	var min_zoom = max(min_zoom_x, min_zoom_y)
	
	# Clamp both the target and actual zoom
	zoomTarget.x = clamp(zoomTarget.x, min_zoom, maxZoom)
	zoomTarget.y = clamp(zoomTarget.y, min_zoom, maxZoom)
	zoom.x = clamp(zoom.x, min_zoom, maxZoom)
	zoom.y = clamp(zoom.y, min_zoom, maxZoom)

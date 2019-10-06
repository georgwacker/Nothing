extends KinematicBody

onready var camera = $Camera
onready var env:WorldEnvironment = $env
onready var text:MeshInstance = $"../text"
onready var switcher = $"../switcher"
onready var prompt = $"../hud/center/spacebar"
onready var dpanel = $"../hud/debug"
onready var dtarget = $"../hud/debug/target"
onready var dcurrent = $"../hud/debug/current"
onready var success = $success

var GRAVITY = -9.8
export var MOUSE_SENSITIVITY = 0.05
export var MOVE_SPEED = 10
var difficulty = 0.03#0.03
var color_step = 0.004
var moves = 0
var bg 
var target
var vel = Vector3()
var done = false
var debug = false

func _ready():
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    bg = env.get_environment().background_color #Color("d3d3d3")
    target = env.get_environment().ambient_light_color
    if dtarget != null:
        dtarget.text = hsv_string(target)
    if debug:
        dpanel.show()
    else:
        dpanel.hide()   

func _physics_process(delta):
    
    var cam = camera.get_global_transform()
    var mov = Vector2()
    var dir = Vector3()
    
    var r = bg.r
    var g = bg.g
    var b = bg.b
    
    var h = bg.h
    var s = bg.s
    var v = bg.v
    
    if Input.is_action_pressed("forward"):
        mov.y += 1
        h -= color_step        
        g -= color_step
        b -= color_step
    if Input.is_action_pressed("backward"):
        mov.y -= 1
        h += color_step                
        g += color_step
        b += color_step
    if Input.is_action_pressed("left"):
        mov.x -= 1
        s -= color_step                
        r -= color_step
        b += color_step
        #b += color_step
    if Input.is_action_pressed("right"):
        mov.x += 1
        s += color_step                
        r += color_step
        b -= color_step
        #g -= color_step
        
    mov = mov.normalized()
    
    dir += -cam.basis.z * mov.y
    dir += cam.basis.x * mov.x
    
    dir.y = 0
    dir = dir.normalized()
    
    r = wrapf(r, 0.0, 0.9)
    g = wrapf(g, 0.0, 0.9)
    b = wrapf(b, 0.0, 0.9)
    
    h = wrapf(h, 0.0, 1.0)
    s = wrapf(s, 0.0, 1.0)

    bg = Color.from_hsv(h,s,v) #Color(r,g,b) 
    env.get_environment().background_color = bg
    
    if dcurrent != null:
        dcurrent.text = hsv_string(bg)
    
    if colors_similar(bg, target):
        set_physics_process(false)
        text.get_surface_material(0).albedo_color = target
        success.play()
        prompt.show()
        done = true
    
    dir *= MOVE_SPEED
    
    vel.y += delta * GRAVITY
    vel.x = dir.x
    vel.z = dir.z
    
    vel = move_and_slide(vel, Vector3(0, 1, 0))

func _input(event):
    if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
        #rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY))
        rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))
    if event.is_action_pressed("ui_cancel"):
        if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
            Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
        else:
            Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
    if event.is_action_pressed("ui_select") and done:
        if switcher.scene != null:
            switcher.next_scene()
        else: # reached the end
            Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
            get_tree().change_scene("res://menu.tscn")
    if event.is_action_pressed("debug"):
        debug != debug
        if debug:
            dpanel.show()
        else:
            dpanel.hide()
        
    
func colors_similar(x, y):
    if abs(x.r - y.r) < difficulty and abs(x.g - y.g) < difficulty and abs(x.b - y.b) < difficulty:
        return true
    else:
        return false

func hsv_string(c:Color):
    return "%.2f %.2f %.2f" % [c.h, c.s, c.v] 

extends WorldEnvironment
# Wetter je nach Ort: Am Sumpf wird der Himmel trüb grünlich-grau und es zieht leichter Nebel auf,
# schon am Ufer. Am Fluss (beim Frosch) und sonst überall bleibt es sonnig. Der Übergang ist weich.

@export var fog_start := 0.02 # ab diesem Wasseranteil ringsum (Karte.swamp_density) beginnt das Sumpfwetter
@export var fog_full := 0.25 # ab hier ist es ganz trüb
@export var blend_speed := 0.7 # wie schnell das Wetter wechselt (pro Sekunde)

# Sonnig / trüb
@export var sunny_top := Color(0.22, 0.48, 0.95)
@export var sunny_horizon := Color(0.65, 0.82, 0.98)
@export var gloomy_top := Color(0.33, 0.4, 0.36)
@export var gloomy_horizon := Color(0.55, 0.6, 0.52)
@export var sunny_fog := 0.005 # ganz wenig, damit der Kartenrand verschwimmt
@export var gloomy_fog := 0.08
@export var sunny_light := 1.2
@export var gloomy_light := 0.5

var gloom := 0.0 # 0 = sonnig, 1 = Sumpfwetter

@onready var player: Node3D = get_node("../Player")
@onready var sun: DirectionalLight3D = get_node("../Sun")
@onready var sky_mat: ProceduralSkyMaterial = environment.sky.sky_material


func _ready() -> void:
	environment.fog_enabled = true
	gloom = _swamp_amount()
	_apply()


func _process(delta: float) -> void:
	var target := move_toward(gloom, _swamp_amount(), blend_speed * delta)
	if target == gloom:
		return # nichts geändert: Himmel nicht neu setzen, sonst berechnet Godot jedes Bild das Himmelslicht neu
	gloom = target
	_apply()


# 0 = sonnig, 1 = Sumpfwetter, je nachdem wie viel Sumpfwasser rings um den Spieler ist.
func _swamp_amount() -> float:
	return smoothstep(fog_start, fog_full, Karte.swamp_density(player.global_position))


func _apply() -> void:
	var top := sunny_top.lerp(gloomy_top, gloom)
	var horizon := sunny_horizon.lerp(gloomy_horizon, gloom)
	sky_mat.sky_top_color = top
	sky_mat.sky_horizon_color = horizon
	sky_mat.ground_horizon_color = horizon
	environment.fog_light_color = horizon
	environment.fog_density = lerpf(sunny_fog, gloomy_fog, gloom)
	sun.light_energy = lerpf(sunny_light, gloomy_light, gloom)

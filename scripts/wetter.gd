extends WorldEnvironment
# Wetter je nach Ort: Ist Sumpfwasser in der Nähe des Spielers, wird der Himmel trüb grünlich-grau
# und es zieht leichter Nebel auf. Weg vom Sumpf ist es sonnig. Der Übergang ist weich.

@export var swamp_radius := 1.5 # so weit um den Spieler wird nach Sumpfwasser gesucht
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
	gloom = move_toward(gloom, _swamp_amount(), blend_speed * delta)
	_apply()


# Anteil Wasser in einem 5x5-Raster um den Spieler; schon ein Viertel Wasser zählt als voller Sumpf.
func _swamp_amount() -> float:
	var hits := 0
	for i in range(-2, 3):
		for j in range(-2, 3):
			if Karte.is_water(player.global_position + Vector3(i, 0, j) * swamp_radius / 2.0):
				hits += 1
	return clampf(hits / 25.0 * 4.0, 0.0, 1.0)


func _apply() -> void:
	var top := sunny_top.lerp(gloomy_top, gloom)
	var horizon := sunny_horizon.lerp(gloomy_horizon, gloom)
	sky_mat.sky_top_color = top
	sky_mat.sky_horizon_color = horizon
	sky_mat.ground_horizon_color = horizon
	environment.fog_light_color = horizon
	environment.fog_density = lerpf(sunny_fog, gloomy_fog, gloom)
	sun.light_energy = lerpf(sunny_light, gloomy_light, gloom)

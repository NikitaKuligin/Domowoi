class_name Karte
extends RefCounted
# Abfragen zur Karte über vorberechnete Bilder (1024 x 1024, decken x und z von -12 bis 12 ab).
# Wassermaske: weiß = Sumpfwasser, schwarz = Land oder Steg.
# Höhenkarte: Boden bzw. Oberkante der Stegbretter; schwarz = HEIGHT_MIN, weiß = HEIGHT_MAX.
# Sumpfgebiet (256 x 256): Wasser plus Inseln und Ufer bis ca. 1 m daneben, hier darf Kikimora laufen.
# Sumpfnebel (256 x 256): Anteil Sumpfwasser im Umkreis von 1,5 m (ohne den Fluss), steuert das Wetter.
# Ändert sich das Gelände, müssen die Bilder neu erzeugt werden.

const EXTENT := 12.0
const HEIGHT_MIN := -0.3
const HEIGHT_MAX := 0.2
const WATER_Y := -0.0229 # Höhe der Wasseroberfläche im Sumpf

static var water_mask: Image = preload("res://textures/swamp/Wassermaske.png").get_image()
static var height_map: Image = preload("res://textures/terrain/Hoehenkarte.png").get_image()
static var swamp_area: Image = preload("res://textures/swamp/Sumpfgebiet.png").get_image()
static var swamp_fog: Image = preload("res://textures/swamp/Sumpfnebel.png").get_image()


static func is_water(p: Vector3) -> bool:
	return _sample(water_mask, p) > 0.5


static func in_swamp(p: Vector3) -> bool:
	return _sample(swamp_area, p) > 0.5


# 0 = kein Sumpfwasser in der Nähe, 1 = nur Wasser ringsum.
static func swamp_density(p: Vector3) -> float:
	return _sample(swamp_fog, p)


static func height(p: Vector3) -> float:
	return lerpf(HEIGHT_MIN, HEIGHT_MAX, _sample(height_map, p))


static func _sample(img: Image, p: Vector3) -> float:
	var size := img.get_size()
	var px := clampi(int((p.x + EXTENT) / (2.0 * EXTENT) * size.x), 0, size.x - 1)
	var pz := clampi(int((p.z + EXTENT) / (2.0 * EXTENT) * size.y), 0, size.y - 1)
	return img.get_pixel(px, pz).r


# Höhe, auf der man steht: Boden oder, wo er tiefer liegt, Wasseroberfläche.
static func surface(p: Vector3) -> float:
	return maxf(height(p), WATER_Y)

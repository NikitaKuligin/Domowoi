extends Control
# Inventarleiste unten am Bildschirm: 9 Felder, am Anfang leer.
# Feld 1 (Index 0) = Krone, Feld 2 = Erdbeeren, Feld 3 = Kolobok, Feld 4 = Wunderblume. Was die Tasten 1-9 tun, steht in player.gd.

const SLOTS := 9
const SLOT_SIZE := 64

var amount: Array[int] = []
var icons: Array[TextureRect] = []
var counts: Array[Label] = []


func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	var bar := HBoxContainer.new()
	bar.add_theme_constant_override("separation", 4)
	bar.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(bar)
	for i in SLOTS:
		bar.add_child(_make_slot(i))
		amount.append(0)
	bar.set_anchors_and_offsets_preset(PRESET_CENTER_BOTTOM, PRESET_MODE_MINSIZE, 16)


func add(slot: int, icon: Texture2D) -> void:
	amount[slot] += 1
	icons[slot].texture = icon
	_refresh(slot)


# Nimmt einen Gegenstand aus dem Feld. Gibt false zurück, wenn das Feld leer ist.
func take(slot: int) -> bool:
	if amount[slot] == 0:
		return false
	amount[slot] -= 1
	if amount[slot] == 0:
		icons[slot].texture = null
	_refresh(slot)
	return true


func has(slot: int) -> bool:
	return amount[slot] > 0


func _refresh(slot: int) -> void:
	counts[slot].text = str(amount[slot]) if amount[slot] > 1 else ""


func _make_slot(i: int) -> Panel:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.12, 0.1, 0.6)
	style.border_color = Color(0.8, 0.8, 0.75, 0.9)
	style.set_border_width_all(3)
	style.set_corner_radius_all(6)
	var slot := Panel.new()
	slot.custom_minimum_size = Vector2(SLOT_SIZE, SLOT_SIZE)
	slot.add_theme_stylebox_override("panel", style)
	slot.mouse_filter = MOUSE_FILTER_IGNORE

	var icon := TextureRect.new()
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.set_anchors_and_offsets_preset(PRESET_FULL_RECT, PRESET_MODE_MINSIZE, 8)
	icon.mouse_filter = MOUSE_FILTER_IGNORE
	slot.add_child(icon)
	icons.append(icon)

	var number := Label.new() # Tastennummer oben links
	number.text = str(i + 1)
	number.position = Vector2(6, 2)
	number.add_theme_font_size_override("font_size", 12)
	number.add_theme_color_override("font_color", Color(1, 1, 1, 0.6))
	slot.add_child(number)

	var count := Label.new() # Anzahl unten rechts, nur ab 2 Stück
	count.set_anchors_and_offsets_preset(PRESET_BOTTOM_RIGHT, PRESET_MODE_MINSIZE, 6)
	count.grow_horizontal = GROW_DIRECTION_BEGIN
	count.grow_vertical = GROW_DIRECTION_BEGIN
	count.add_theme_font_size_override("font_size", 18)
	count.add_theme_constant_override("outline_size", 4)
	count.add_theme_color_override("font_outline_color", Color.BLACK)
	slot.add_child(count)
	counts.append(count)
	return slot

extends "res://scripts/rules_base.gd"

var player_x := 0.5
var enemies: Array[Vector2] = []
var bullets: Array[Vector2] = []
var spawn_clock := 0.0
var fire_clock := 0.0
var lives := 3


func _init() -> void:
	title = "Space Shooter"
	subtitle = "Mova a nave e derrote as ondas"


func reset() -> void:
	super.reset()
	player_x = 0.5
	enemies.clear()
	bullets.clear()
	spawn_clock = 0.0
	fire_clock = 0.0
	lives = 3


func pointer(p: Vector2) -> void:
	player_x = clampf(p.x, 0.07, 0.93)


func tap(p: Vector2) -> void:
	pointer(p)
	fire()


func swipe(_a: Vector2, b: Vector2) -> void:
	pointer(b)


func fire() -> void:
	if not ended and bullets.size() < 10:
		bullets.append(Vector2(player_x, 0.85))


func tick(delta: float) -> void:
	spawn_clock += delta
	fire_clock += delta
	while fire_clock >= 0.28:
		fire_clock -= 0.28
		fire()
	var spawn_interval := maxf(0.28, 0.83 - score * 0.008)
	while spawn_clock >= spawn_interval:
		spawn_clock -= spawn_interval
		enemies.append(Vector2(randf_range(0.08, 0.92), -0.05))
	for i in range(bullets.size() - 1, -1, -1):
		bullets[i] += Vector2.UP * delta * 1.03
		if bullets[i].y < -0.1:
			bullets.remove_at(i)
	for i in range(enemies.size() - 1, -1, -1):
		enemies[i] += Vector2.DOWN * delta * (0.23 + minf(0.23, score * 0.006))
		if enemies[i].y > 1.05:
			enemies.remove_at(i)
			lives -= 1
			continue
		if enemies[i].distance_to(Vector2(player_x, 0.87)) < 0.065:
			enemies.remove_at(i)
			lives -= 1
			continue
		for j in range(bullets.size() - 1, -1, -1):
			if enemies[i].distance_to(bullets[j]) < 0.055:
				enemies.remove_at(i)
				bullets.remove_at(j)
				score += 10
				break
	if lives <= 0:
		ended = true
		message = "Sua nave foi atingida!"


func draw_game(canvas: CanvasItem, area: Rect2) -> void:
	canvas.draw_rect(area, Color("121d42"))
	for i in range(55):
		var p := area.position + Vector2(float((i * 127 + 43) % 1000) / 1000.0 * area.size.x, float((i * 317 + 91) % 1000) / 1000.0 * area.size.y)
		canvas.draw_circle(p, 1.3 + float(i % 3), Color("bcd0ff"))
	for enemy in enemies:
		if enemy.y >= 18.0 / area.size.y and enemy.y <= 1.0 - 18.0 / area.size.y:
			canvas.draw_circle(area.position + enemy * area.size, 18, Color("f57a7f"))
	for shot in bullets:
		var shot_rect := Rect2(area.position + shot * area.size - Vector2(3, 10), Vector2(6, 20)).intersection(area)
		if shot_rect.has_area(): canvas.draw_rect(shot_rect, Color("9df6d4"))
	var center := area.position + Vector2(player_x * area.size.x, area.size.y * 0.87)
	canvas.draw_colored_polygon(PackedVector2Array([center + Vector2(0, -26), center + Vector2(-22, 21), center + Vector2(22, 21)]), Color("76d1f7"))
	label(canvas, "Vidas: %d" % lives, area.position + Vector2(area.size.x * 0.5, 42), 25, Color("ffffff"))

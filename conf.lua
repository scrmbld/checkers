function love.conf(t)
	t.version = "11.5"

	t.window.width = 1280
	t.window.height = 720

	t.modules.joystick = false
	t.modules.physics = false
	t.modules.data = false

	t.window.title = "Checkers"
end

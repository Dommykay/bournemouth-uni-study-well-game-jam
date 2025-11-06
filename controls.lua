_G.keybinds = {}

keybinds.up = love.keyboard.isDown("up")
keybinds.down = love.keyboard.isDown("down")
keybinds.left = love.keyboard.isDown("left")
keybinds.right = love.keyboard.isDown("right")

keybinds.mouse1 = love.mouse.isDown(1)
keybinds.space = love.keyboard.isDown("space")

function love.keypressed(key, scancode, isrepeat)
    -- Add key presses since table last flushed
    local in_table = false
    if #key_presses_frame > 0 then
        for _,table_key in pairs(key_presses_frame) do
            if key == table_key then
                in_table = true
            end
        end
    end
    if not in_table then
        table.insert(key_presses_frame, key)
    end

end

function love.mousepressed(x, y, button, isTouch)
    -- Add key presses since table last flushed (mouse edition)
    local in_table = false
    if #key_presses_frame > 0 then
        for _,table_key in pairs(key_presses_frame) do
            if button == table_key then
                in_table = true
            end
        end
    end
    if not in_table then
        table.insert(key_presses_frame, button)
    end

end
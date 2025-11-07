_G.keybinds = {}

keybinds.up =       function () return love.keyboard.isDown("up") or love.keyboard.isDown("w") end
keybinds.down =     function () return love.keyboard.isDown("down") or love.keyboard.isDown("s") end
keybinds.left =     function () return love.keyboard.isDown("left") or love.keyboard.isDown("a")end
keybinds.right =    function () return love.keyboard.isDown("right") or love.keyboard.isDown("d")end
keybinds.mouse1 =   function () return love.mouse.isDown(1) end
keybinds.space =    function () return love.keyboard.isDown("space") end

keybinds.slash = function () 
    if #key_presses_frame > 0 then
        for pos,table_key in pairs(key_presses_frame) do
            local removed = false
            if "space" == table_key then
                table.remove(key_presses_frame, pos)
                removed = true
            end
            if 1 == table_key then
                table.remove(key_presses_frame, pos)
                removed = true
            end
            if removed then
                return true
            end
        end
    end
    return false
end

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
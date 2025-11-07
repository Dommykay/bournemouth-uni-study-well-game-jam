function ReturnEnemy(direction, damage, time)
    local enemy = {}
    
    local centre_distance = 1000
    
    if damage == nil then
        damage = 0.1
    end

    if time == nil then
        time = 3
    end

    enemy.damage = damage
    enemy.size = 5
    enemy.current_position = function() enemy.position_tween.ReturnValue() end
    enemy.marked_for_death = false

    if direction == "d" then
        enemy.starting_position = (RES/2) + vector.new(0,centre_distance)
        enemy.texture = love.graphics.newImage("assets/textures/enemies/down_enemy.png")
        enemy.position_tween = CreateTweenVector(enemy.starting_position, button_positions.down, 3, time-3, "root")

    elseif direction == "l" then
        enemy.starting_position = (RES/2) + vector.new(-centre_distance,0)
        enemy.texture = love.graphics.newImage("assets/textures/enemies/left_enemy.png")
        enemy.position_tween = CreateTweenVector(enemy.starting_position, button_positions.left, 3, time-3, "root")
        
    elseif direction == "r" then
        enemy.starting_position = (RES/2) + vector.new(centre_distance,0)
        enemy.texture = love.graphics.newImage("assets/textures/enemies/right_enemy.png")
        enemy.position_tween = CreateTweenVector(enemy.starting_position, button_positions.right, 3, time-3, "root")
        
    else -- Assume U direction
        enemy.starting_position = (RES/2) + vector.new(0,-centre_distance)
        enemy.texture = love.graphics.newImage("assets/textures/enemies/up_enemy.png")
        enemy.position_tween = CreateTweenVector(enemy.starting_position, button_positions.up, 3, time-3, "root")
    end

    enemy.Update = function (dt)
        enemy.current_position = enemy.current_position + (enemy.speed*dt)
    end


    enemy.Render = function()
        local x, y = (enemy.position_tween.ReturnValue()):unpack()
        local a, _ = (enemy.position_tween.ReturnProgress()):unpack()
        local r,g,b,_ = menu.song.average_colour:unpack()
        love.graphics.setColor(r,g,b,a)
        love.graphics.draw(enemy.texture, x, y, 0, enemy.size, enemy.size, enemy.texture:getWidth()/2, enemy.texture:getHeight()/2)
        love.graphics.setColor(r,g,b,1)
    end

    enemy.CheckHit = function ()
        local progress, _ = (enemy.position_tween.ReturnProgress()):unpack()
        
        if progress < 0.96 then
            return "miss"
        elseif progress < 0.97 then
            enemy.marked_for_death = true
            return "good"
        elseif progress < 0.98 then
            enemy.marked_for_death = true
            return "great"
        end
        enemy.marked_for_death = true
        return "perfect"
    end

    return enemy
end
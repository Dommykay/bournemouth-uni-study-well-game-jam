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

    if direction == "d" then
        enemy.starting_position = (RES/2) + vector.new(0,centre_distance)
        enemy.texture = love.graphics.newImage("assets/textures/enemies/down_enemy.png")
        enemy.position_tween = CreateTweenVector(enemy.starting_position, button_positions.down, time, time-3, "linear")

    elseif direction == "l" then
        enemy.starting_position = (RES/2) + vector.new(-centre_distance,0)
        enemy.texture = love.graphics.newImage("assets/textures/enemies/left_enemy.png")
        enemy.position_tween = CreateTweenVector(enemy.starting_position, button_positions.left, time, time-3, "linear")
        
    elseif direction == "r" then
        enemy.starting_position = (RES/2) + vector.new(centre_distance,0)
        enemy.texture = love.graphics.newImage("assets/textures/enemies/right_enemy.png")
        enemy.position_tween = CreateTweenVector(enemy.starting_position, button_positions.right, time, time-3, "linear")
        
    else -- Assume U direction
        enemy.starting_position = (RES/2) + vector.new(0,-centre_distance)
        enemy.texture = love.graphics.newImage("assets/textures/enemies/up_enemy.png")
        enemy.position_tween = CreateTweenVector(enemy.starting_position, button_positions.up, time, time-3, "linear")
    end

    enemy.Update = function (dt)
        enemy.current_position = enemy.current_position + (enemy.speed*dt)
    end


    enemy.Render = function()
        local x, y = (enemy.position_tween.ReturnValue()):unpack()
        print(enemy.position_tween.x.time_from_start(), enemy.position_tween.y.time_from_start())
        love.graphics.draw(enemy.texture, x, y, 0, enemy.size, enemy.size, enemy.texture:getWidth()/2, enemy.texture:getHeight()/2)
    end

    enemy.CheckHit = function ()
        
    end

    return enemy
end
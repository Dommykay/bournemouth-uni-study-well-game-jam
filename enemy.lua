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

    if direction == "d" then
        enemy.starting_position = (RES/2) + vector.new(0,centre_distance)
        enemy.texture = love.graphics.newImage("assets/textures/enemies/down_enemy.png")
        enemy.speed = vector.new(0,-1000/time)

    elseif direction == "l" then
        enemy.starting_position = (RES/2) + vector.new(-centre_distance,0)
        enemy.texture = love.graphics.newImage("assets/textures/enemies/left_enemy.png")
        enemy.speed = vector.new(1000/time,0)
        
    elseif direction == "r" then
        enemy.starting_position = (RES/2) + vector.new(centre_distance,0)
        enemy.texture = love.graphics.newImage("assets/textures/enemies/right_enemy.png")
        enemy.speed = vector.new(-1000/time,0)
        
    else -- Assume U direction
        enemy.starting_position = (RES/2) + vector.new(0,-centre_distance)
        enemy.texture = love.graphics.newImage("assets/textures/enemies/up_enemy.png")
        enemy.speed = vector.new(0,1000/time)
    end

    enemy.current_position = enemy.starting_position

    enemy.Update = function (dt)
        enemy.current_position = enemy.current_position + (enemy.speed*dt)
    end


    enemy.Render = function()
        love.graphics.draw(enemy.texture, enemy.current_position.x,enemy.current_position.y, 0, enemy.size, enemy.size, enemy.texture:getWidth()/2, enemy.texture:getHeight()/2)
    end

    return enemy
end
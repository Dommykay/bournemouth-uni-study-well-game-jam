-- Queuing music to queueable source copied from love2d.org/wiki/Decoder and edited to purpose

_G.enemy = require("enemy")


function ReturnGame(song)
    local game = {}


    game.Init = function ()
        if song == nil then
            game.song = {}
            game.song.decoder = love.sound.newDecoder("assets/songs/Alright/song.wav")
            game.song.queueableSource = love.audio.newQueueableSource(game.song.decoder:getSampleRate(), game.song.decoder:getBitDepth(), game.song.decoder:getChannelCount())
        else
            game.song = {}
            game.song.decoder = love.sound.newDecoder((song_list[menu.selected_song].folder_path)..menu.song.file_extension)
            game.song.queueableSource = love.audio.newQueueableSource(game.song.decoder:getSampleRate(), game.song.decoder:getBitDepth(), game.song.decoder:getChannelCount())
            
            love.graphics.setColor(song.average_colour:unpack())
        end
        game.time_started = love.timer.getTime()
        game.song_started = false -- This is probably more efficient than checking if it actually is playing thru the love module? ion kno
        game.enemy_storage = {}
        -- Looks weird but will be more efficient this way as i want to only look at the closest thing in a certain direction.
        game.enemy_storage.up = {}
        game.enemy_storage.down = {}
        game.enemy_storage.left = {}
        game.enemy_storage.right = {}

        game.score = 0
        game.perfect_streak = 0
        game.player_health = 1
        game.most_recent_slash = "miss"

        game.loadEnemiesFromLevel((song_list[menu.selected_song].folder_path).."/level.json")
        
    end


    game.BufferSong = function ()
        local freeBufferCount = game.song.queueableSource:getFreeBufferCount()
        for i = 1, freeBufferCount do
            local soundData = game.song.decoder:decode()
            if soundData then
                game.song.queueableSource:queue(soundData)
            end
        end
    end

    game.StartSong = function ()
        game.BufferSong()
        game.song.queueableSource:play()
        game.song_started = true
    end

    game.Update = function (dt)
        game.BufferSong()
        --game.GetEnemiesDueSpawning()
        game.PlayerKillEnemies()
        game.EnemiesDamagePlayer()
        --game.LaserDamagePlayer()

        if game.perfect_streak > menu.last_game.highest_streak then
            menu.last_game.highest_streak = game.perfect_streak
        end
    end

    game.Render = function ()
        local up, down, left, right = textures.buttons.up, textures.buttons.down, textures.buttons.left, textures.buttons.right
        local up_pos, down_pos, left_pos, right_pos = button_positions.up, button_positions.down, button_positions.left, button_positions.right
        local zoom = 5


        love.graphics.draw(up, up_pos.x, up_pos.y, 0, zoom, zoom, up:getWidth()/2,up:getHeight()/2)
        love.graphics.draw(down, down_pos.x, down_pos.y, 0, zoom, zoom, down:getWidth()/2,down:getHeight()/2)
        love.graphics.draw(left, left_pos.x, left_pos.y, 0, zoom, zoom, left:getWidth()/2,left:getHeight()/2)
        love.graphics.draw(right, right_pos.x, right_pos.y, 0, zoom, zoom, right:getWidth()/2,right:getHeight()/2)

        game.DrawAppropriateScoreDecal()

        love.graphics.printf("Health: "..math.floor(game.player_health*100).."%", LIGHT_FONT, RES.x/2, RES.y/2+50, 9999, "left", 0, 1, 1, 200, -60)

        love.graphics.printf("Score: "..game.score, LIGHT_FONT, RES.x/2, RES.y/2+90, 9999, "left", 0, 1, 1, 200, -60)

        game.RenderEnemies()
    end

    game.DrawAppropriateScoreDecal = function ()

        love.graphics.setColor(1,1,1,1)

        if game.most_recent_slash == "miss" then
            return
        end

        if game.most_recent_slash == "good" then
            love.graphics.draw(textures.score_displays.good, RES.x/2, RES.y/2, 0, 3, 3, textures.score_displays.good:getWidth()/2,textures.score_displays.good:getHeight()/2)
            return
        end

        if game.most_recent_slash == "great" then
            love.graphics.draw(textures.score_displays.great, RES.x/2, RES.y/2, 0, 3, 3, textures.score_displays.great:getWidth()/2,textures.score_displays.great:getHeight()/2)
            return
        end

        if game.most_recent_slash == "perfect" then
            if game.perfect_streak == 2 then
                love.graphics.draw(textures.score_displays.x2, RES.x/2, RES.y/2-40, 0, 6, 6, textures.score_displays.x2:getWidth()/2,textures.score_displays.x2:getHeight()/2)
            end
            if game.perfect_streak == 3 then
                love.graphics.draw(textures.score_displays.x3, RES.x/2, RES.y/2-40, 0, 6, 6, textures.score_displays.x3:getWidth()/2,textures.score_displays.x3:getHeight()/2)
            end
            if game.perfect_streak == 4 then
                love.graphics.draw(textures.score_displays.x4, RES.x/2, RES.y/2-40, 0, 6, 6, textures.score_displays.x4:getWidth()/2,textures.score_displays.x4:getHeight()/2)
            end
            if game.perfect_streak == 5 then
                love.graphics.draw(textures.score_displays.x5, RES.x/2, RES.y/2-40, 0, 6, 6, textures.score_displays.x5:getWidth()/2,textures.score_displays.x5:getHeight()/2)
            end
            if game.perfect_streak > 5 then
                love.graphics.draw(textures.score_displays.amazing, RES.x/2, RES.y/2, 0, 3, 3, textures.score_displays.amazing:getWidth()/2,textures.score_displays.amazing:getHeight()/2)
            else
                love.graphics.draw(textures.score_displays.perfect, RES.x/2, RES.y/2, 0, 3, 3, textures.score_displays.perfect:getWidth()/2,textures.score_displays.perfect:getHeight()/2)
            end
        end

        love.graphics.setColor(menu.song.average_colour:unpack())

    end


    game.GetEnemiesDueSpawning = function ()



        if (#game.enemy_storage.up + #game.enemy_storage.down + #game.enemy_storage.left + #game.enemy_storage.right) < 1 then
            for i=1,1000 do
                table.insert(game.enemy_storage.up, ReturnEnemy("u", 0.1, i*0.5+5))
            end
            table.insert(game.enemy_storage.up, ReturnEnemy("u", 0.1, 3))
            table.insert(game.enemy_storage.down, ReturnEnemy("d", 0.1, 3))
            table.insert(game.enemy_storage.left, ReturnEnemy("l", 0.1, 3))
            table.insert(game.enemy_storage.right, ReturnEnemy("r", 0.1, 3))
            table.insert(game.enemy_storage.up, ReturnEnemy("u", 0.1, 4))
            table.insert(game.enemy_storage.up, ReturnEnemy("u", 0.1, 5))
            table.insert(game.enemy_storage.up, ReturnEnemy("u", 0.1, 6))
        end
    end

    game.RenderEnemies = function ()
        if #game.enemy_storage.up > 0 then
            for index,enemy in pairs(game.enemy_storage.up) do
                enemy.Render()
            end
        end
        if #game.enemy_storage.down > 0 then
            for index,enemy in pairs(game.enemy_storage.down) do
                enemy.Render()
            end
        end
        if #game.enemy_storage.left > 0 then
            for index,enemy in pairs(game.enemy_storage.left) do
                enemy.Render()
            end
        end
        if #game.enemy_storage.right > 0 then
            for index,enemy in pairs(game.enemy_storage.right) do
                enemy.Render()
            end
        end 
    end

    game.CheckHitEnemies = function (direction)

        if direction == "d" then
            if #game.enemy_storage.down > 0 then
                for index,enemy in pairs(game.enemy_storage.down) do
                    local progress, _ = (enemy.position_tween.ReturnProgress()):unpack()
                    if progress > 0.93 then

                        game.most_recent_slash = game.enemy_storage.down[index].CheckHit()
                        if game.most_recent_slash == "miss" then
                            game.perfect_streak = 0
                        elseif game.most_recent_slash == "good" then
                            game.score = game.score + 100
                            game.perfect_streak = 0
                            break
                        elseif game.most_recent_slash == "great" then
                            game.score = game.score + (500*(game.perfect_streak+1))
                            break
                        else
                            game.score = game.score + (1000*(game.perfect_streak+1))
                            game.perfect_streak = game.perfect_streak + 1
                            break
                        end

                    end
                end
            end 
        elseif direction == "l" then
            if #game.enemy_storage.left > 0 then
                for index,enemy in pairs(game.enemy_storage.left) do
                    local progress, _ = (enemy.position_tween.ReturnProgress()):unpack()
                    if progress > 0.93 then

                        game.most_recent_slash = game.enemy_storage.left[index].CheckHit()
                        if game.most_recent_slash == "miss" then
                            game.perfect_streak = 0
                        elseif game.most_recent_slash == "good" then
                            game.score = game.score + 100
                            game.perfect_streak = 0
                            break
                        elseif game.most_recent_slash == "great" then
                            game.score = game.score + (500*(game.perfect_streak+1))
                            break
                        else
                            game.score = game.score + (1000*(game.perfect_streak+1))
                            game.perfect_streak = game.perfect_streak + 1
                            break
                        end

                    end
                end
            end
        elseif direction == "r" then
            if #game.enemy_storage.right > 0 then
                for index,enemy in pairs(game.enemy_storage.right) do
                    local progress, _ = (enemy.position_tween.ReturnProgress()):unpack()
                    if progress > 0.93 then

                        game.most_recent_slash = game.enemy_storage.right[index].CheckHit()
                        if game.most_recent_slash == "miss" then
                            game.perfect_streak = 0
                        elseif game.most_recent_slash == "good" then
                            game.score = game.score + 100
                            game.perfect_streak = 0
                            break
                        elseif game.most_recent_slash == "great" then
                            game.score = game.score + (500*(game.perfect_streak+1))
                            break
                        else
                            game.score = game.score + (1000*(game.perfect_streak+1))
                            game.perfect_streak = game.perfect_streak + 1
                            break
                        end

                    end
                end
            end
        else
            if #game.enemy_storage.up > 0 then
                for index,enemy in pairs(game.enemy_storage.up) do
                    local progress, _ = (enemy.position_tween.ReturnProgress()):unpack()
                    if progress > 0.93 then

                        game.most_recent_slash = game.enemy_storage.up[index].CheckHit()
                        if game.most_recent_slash == "miss" then
                            game.perfect_streak = 0
                        elseif game.most_recent_slash == "good" then
                            game.score = game.score + 100
                            game.perfect_streak = 0
                            break
                        elseif game.most_recent_slash == "great" then
                            game.score = game.score + (500*(game.perfect_streak+1))
                            break
                        else
                            game.score = game.score + (1000*(game.perfect_streak+1))
                            game.perfect_streak = game.perfect_streak + 1
                            break
                        end

                    end
                end
            end
        end
            
    end

    function game.PlayerKillEnemies()

        local up,down,left,right = keybinds.up(),keybinds.down(), keybinds.left(), keybinds.right()
        if keybinds.slash() then
            print(true)
            if up then
                game.CheckHitEnemies("u")
            end
            if down then
                game.CheckHitEnemies("d")
            end
            if left then
                game.CheckHitEnemies("l")
            end
            if right then
                game.CheckHitEnemies("r")
            end
        else
            print(false)
        end
        if #game.enemy_storage.up > 0 then
            for index,enemy in pairs(game.enemy_storage.up) do
                if enemy.marked_for_death then
                    table.remove(game.enemy_storage.up, index)
                    game.regen_health()
                end
            end
        end
        if #game.enemy_storage.down > 0 then
            for index,enemy in pairs(game.enemy_storage.down) do
                if enemy.marked_for_death then
                    table.remove(game.enemy_storage.down, index)
                    game.regen_health()
                end
            end
        end
        if #game.enemy_storage.left > 0 then
            for index,enemy in pairs(game.enemy_storage.left) do
                if enemy.marked_for_death then
                    table.remove(game.enemy_storage.left, index)
                    game.regen_health()
                end
            end
        end
        if #game.enemy_storage.right > 0 then
            for index,enemy in pairs(game.enemy_storage.right) do
                if enemy.marked_for_death then
                    table.remove(game.enemy_storage.right, index)
                    game.regen_health()
                end
            end
        end
    end



    function game.EnemiesDamagePlayer()

        if #game.enemy_storage.up > 0 then
            for index,enemy in pairs(game.enemy_storage.up) do
                local progress, _ = (enemy.position_tween.ReturnProgress()):unpack()
                if progress > 0.99999 then
                    table.remove(game.enemy_storage.up, index)
                    game.player_health = game.player_health - enemy.damage/math.max(game.perfect_streak,1)
                    game.perfect_streak = 0
                    game.most_recent_slash = "miss"
                end
            end
        end
        if #game.enemy_storage.down > 0 then
            for index,enemy in pairs(game.enemy_storage.down) do
                local progress, _ = (enemy.position_tween.ReturnProgress()):unpack()
                if progress > 0.99999 then
                    table.remove(game.enemy_storage.down, index)
                    game.player_health = game.player_health - enemy.damage/math.max(game.perfect_streak,1)
                    game.perfect_streak = 0
                    game.most_recent_slash = "miss"
                end
            end
        end
        if #game.enemy_storage.left > 0 then
            for index,enemy in pairs(game.enemy_storage.left) do
                local progress, _ = (enemy.position_tween.ReturnProgress()):unpack()
                if progress > 0.99999 then
                    table.remove(game.enemy_storage.left, index)
                    game.player_health = game.player_health - enemy.damage/math.max(game.perfect_streak,1)
                    game.perfect_streak = 0
                    game.most_recent_slash = "miss"
                end
            end
        end
        if #game.enemy_storage.right > 0 then
            for index,enemy in pairs(game.enemy_storage.right) do
                local progress, _ = (enemy.position_tween.ReturnProgress()):unpack()
                if progress > 0.99999 then
                    table.remove(game.enemy_storage.right, index)
                    game.player_health = game.player_health - enemy.damage/math.max(game.perfect_streak,1)
                    game.perfect_streak = 0
                    game.most_recent_slash = "miss"
                end
            end
        end
    end

    function game.regen_health()
        if game.player_health < 1 then
            game.player_health = math.min(game.player_health + math.max(0.05*(game.perfect_streak - 2),0), 1)
        end
    end

    -- GENERATED BY GOOGLE GEMINI AI 

    -- This module's functions are intended to be added to the global 'game' table.
    -- It assumes 'game.loadLevelData' already exists.

    --- Loads all enemies from a level file, calculates their
    -- absolute spawn time, and stores them in the global 'game.enemy_storage' list.
    -- This is an "unsafe" version that assumes all data in the
    -- JSON file is 100% valid and will crash if it is not.
    -- It assumes 'game.enemy_storage' and 'ReturnEnemy' exist in the global scope.
    -- @param levelFilename (string) The path to the level.json file.
    function game.loadEnemiesFromLevel(levelFilename)
        
        -- 1. Load the level data (assumes game.loadLevelData exists)
        local levelData = loadJSONData(levelFilename)

        -- Add a minimal guard clause to stop execution if loading failed.
        -- This satisfies type-checkers without full error handling.
        if not levelData then
            return
        end


        -- 2. Iterate over all top-level keys (the timestamps)
        for timestampKey, timestampData in pairs(levelData) do
            
            -- 3. Convert timestamp key to a number
            local timestampValue = tonumber(timestampKey)
            
            -- 4. Check if it's a valid non-negative timestamp (>= 0)
            --    and if it has an 'enm' table to process.
            if timestampValue and timestampValue >= 0 and timestampData.enm then
                
                -- 5. Iterate over all enemies for this timestamp (assumes 'enm' exists)
                for id, enemy in pairs(timestampData.enm) do
                    
                    -- 6. Calculate the total spawn time (assumes 'time' exists and is a number)
                    local enemyTime = tonumber(enemy.time)
                    local totalSpawnTime = timestampValue + enemyTime
                    
                    -- 7. Call the global function (assumes 'dir' and 'dmg' exist)
                    local newEnemyObject = ReturnEnemy(enemy.dir, enemy.dmg, totalSpawnTime)
                    
                    -- 8. Insert the new enemy into the global storage list
                    if enemy.dir == "u" then
                        table.insert(game.enemy_storage.up, newEnemyObject)
                    elseif enemy.dir == "d" then
                        table.insert(game.enemy_storage.down, newEnemyObject)
                    elseif enemy.dir == "l" then
                        table.insert(game.enemy_storage.left, newEnemyObject)
                    else
                        table.insert(game.enemy_storage.right, newEnemyObject)
                    end
                end
            end
        end
    end

    -- --- Example Usage ---
    -- (This version is faster but will error on bad data)
    --
    -- -- In your main.lua file:
    --
    -- -- 1. Your game table and ReturnEnemy function MUST be global
    -- game = {
    --     enemy_storage = {} -- This is the table we will populate
    -- }
    --
    -- -- 1b. Load and assign the level loader
    -- game.loadLevelData = require("level_loader")
    --
    -- -- 1c. Load this script (e.g., using dofile() or require())
    -- -- require("enemy_spawner_unsafe") -- This will add the function to 'game'
    --
    -- function ReturnEnemy(direction, damage, totalSpawnTime)
    --     -- It returns a table (or "object")
    --     return {
    --         dir = direction,
    --         dmg = tonumber(damage),
    --         spawn_time = totalSpawnTime, -- Store the new calculated time
    --         is_active = false
    --     }
    -- end
    --
    -- -- 3. (This step is now done by loading the file)
    --
    -- -- 4. Call the function once at the start of your game
    -- game.loadEnemiesFromLevel_unsafe("level.json")
    --
    -- -- 5. Now, game.enemy_storage is populated!
    -- -- print("Total enemies loaded: " .. #game.enemy_storage)
    -- -- for i, enemy in ipairs(game.enemy_storage) do
    -- --     print("  Enemy " .. i .. " spawns at: " .. enemy.spawn_time)
    -- -- end


    -- No return statement; the function is attached to the 'game' table directly.




    -- END OF AI GENERATION

    return game
end

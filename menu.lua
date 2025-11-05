function ReturnMenu()
    local menu = {}
    menu.current_scene = "main"
    menu.song_list = song_list
    menu.transition_finished = false

    menu.BufferSong = function ()
        local freeBufferCount = menu.song.queueableSource:getFreeBufferCount()
        for i = 1, freeBufferCount do
            local soundData = menu.song.decoder:decode()
            menu.song.queueableSource:queue(soundData)
        end
    end

    menu.selected_song = 1
    menu.song = {}
    menu.song.cover = love.graphics.newImage((menu.song_list[menu.selected_song].folder_path).."/cover.png")
    menu.song.decoder = love.sound.newDecoder((menu.song_list[menu.selected_song].folder_path).."/song.wav")
    menu.song.queueableSource = love.audio.newQueueableSource(menu.song.decoder:getSampleRate(), menu.song.decoder:getBitDepth(), menu.song.decoder:getChannelCount())
    menu.BufferSong()
    menu.song.queueableSource:play()

    function menu.Update()
        menu.BufferSong()
    end



    function menu.Render()
        local up, down, left, right = textures.buttons.up, textures.buttons.down, textures.buttons.left, textures.buttons.right
        local up_pos, down_pos, left_pos, right_pos = button_positions.up, button_positions.down, button_positions.left, button_positions.right
        if menu.current_scene == "main" or menu.current_scene == "transition" then
            local zoom = 5
            love.graphics.draw(up, up_pos.x, up_pos.y, 0, zoom, zoom, up:getWidth()/2,up:getHeight()/2)
            love.graphics.draw(down, down_pos.x, down_pos.y, 0, zoom, zoom, down:getWidth()/2,down:getHeight()/2)
            love.graphics.draw(left, left_pos.x, left_pos.y, 0, zoom, zoom, left:getWidth()/2,left:getHeight()/2)
            love.graphics.draw(right, right_pos.x, right_pos.y, 0, zoom, zoom, right:getWidth()/2,right:getHeight()/2)
            
            love.graphics.printf("Settings", LIGHT_FONT, left_pos.x, left_pos.y, 9999, "left", 0, 0.7, 0.7, 105, -60)
            love.graphics.printf("Select song", LIGHT_FONT, right_pos.x, right_pos.y, 9999, "left", 0, 0.7, 0.7, 150, -60)
            love.graphics.printf("Next song", LIGHT_FONT, down_pos.x, down_pos.y, 9999, "left", 0, 0.7, 0.7, 125, -60)
            love.graphics.printf("Previous song", LIGHT_FONT, up_pos.x, up_pos.y, 9999, "left", 0, 0.7, 0.7, 175, -60)

            -- Album cover
            local cover_zoom = 0.25
            love.graphics.draw(menu.song.cover, 25, 25, 0, cover_zoom, cover_zoom)

            -- Title
            local name_limit = string.sub(song_list[menu.selected_song].song_info["title"], 1, math.min(#(song_list[menu.selected_song].song_info["title"]),10))
            if #(song_list[menu.selected_song].song_info["title"]) > 11 then
                name_limit = name_limit.."..."
            end
            love.graphics.printf(name_limit, LIGHT_FONT, 25, 300, 9999, "left", 0, 1, 1)

            -- Artist
            local name_limit = string.sub(song_list[menu.selected_song].song_info["artist"], 1, math.min(#(song_list[menu.selected_song].song_info["artist"]),10))
            if #(song_list[menu.selected_song].song_info["artist"]) > 11 then
                name_limit = name_limit.."..."
            end
            love.graphics.printf(name_limit, LIGHT_FONT, 25, 360, 9999, "left", 0, 0.5, 0.5)

            -- Duration
            local name_limit = string.sub(song_list[menu.selected_song].song_info["duration"], 1, math.min(#(song_list[menu.selected_song].song_info["duration"]),10))
            if #(song_list[menu.selected_song].song_info["duration"]) > 11 then
                name_limit = name_limit.."..."
            end
            love.graphics.printf(name_limit, LIGHT_FONT, 25, 390, 9999, "left", 0, 0.5, 0.5)
            
        end

        if menu.current_scene == "settings" then
            local zoom = 5
            love.graphics.draw(up, up_pos.x, up_pos.y, 0, zoom, zoom, up:getWidth()/2,up:getHeight()/2)
            love.graphics.draw(down, down_pos.x, down_pos.y, 0, zoom, zoom, down:getWidth()/2,down:getHeight()/2)
            love.graphics.draw(left, left_pos.x, left_pos.y, 0, zoom, zoom, left:getWidth()/2,left:getHeight()/2)
            love.graphics.draw(right, right_pos.x, right_pos.y, 0, zoom, zoom, right:getWidth()/2,right:getHeight()/2)
            
            love.graphics.printf("Back", LIGHT_FONT, left_pos.x, left_pos.y, 9999, "left", 0, 0.7, 0.7, 65, -60)
            love.graphics.printf("temp", LIGHT_FONT, right_pos.x, right_pos.y, 9999, "left", 0, 0.7, 0.7, 65, -60)
            love.graphics.printf("temp", LIGHT_FONT, down_pos.x, down_pos.y, 9999, "left", 0, 0.7, 0.7, 65, -60)
            love.graphics.printf("temp", LIGHT_FONT, up_pos.x, up_pos.y, 9999, "left", 0, 0.7, 0.7, 65, -60)
        end

    end

    function menu.Navigate()
        if menu.current_scene == "main" then
            if #key_presses_frame > 0 then
                for _,key in pairs(key_presses_frame) do

                    if key == "left" then
                        menu.current_scene = "settings"
                        menu.song.queueableSource:stop()
                        
                    end

                    if key == "right" then
                        menu.current_scene = "transition"
                        menu.song.queueableSource:stop()
                        
                    end

                    if key == "up" then
                        menu.selected_song = menu.selected_song - 1
                        if menu.selected_song < 1 then
                            menu.selected_song = #song_list
                        end
                        menu.song.queueableSource:stop()
                        menu.song.cover = love.graphics.newImage((song_list[menu.selected_song].folder_path).."/cover.png")
                        menu.song.decoder = love.sound.newDecoder((song_list[menu.selected_song].folder_path).."/song.wav")
                        menu.song.queueableSource = love.audio.newQueueableSource(menu.song.decoder:getSampleRate(), menu.song.decoder:getBitDepth(), menu.song.decoder:getChannelCount())
                        menu.BufferSong()
                        menu.song.queueableSource:play()
                    end

                    if key == "down" then
                        menu.selected_song = menu.selected_song + 1
                        if menu.selected_song > #song_list then
                            menu.selected_song = 1
                        end
                        menu.song.queueableSource:stop()
                        menu.song.cover = love.graphics.newImage((song_list[menu.selected_song].folder_path).."/cover.png")
                        menu.song.decoder = love.sound.newDecoder((song_list[menu.selected_song].folder_path).."/song.wav")
                        menu.song.queueableSource = love.audio.newQueueableSource(menu.song.decoder:getSampleRate(), menu.song.decoder:getBitDepth(), menu.song.decoder:getChannelCount())
                        menu.BufferSong()
                        menu.song.queueableSource:play()
                    end

                end
            end
        elseif menu.current_scene == "settings" then
            if #key_presses_frame > 0 then
                for _,key in pairs(key_presses_frame) do
                    if key == "left" then
                        menu.current_scene = "main"
                        menu.song.decoder = love.sound.newDecoder((song_list[menu.selected_song].folder_path).."/song.wav")
                        menu.song.queueableSource = love.audio.newQueueableSource(menu.song.decoder:getSampleRate(), menu.song.decoder:getBitDepth(), menu.song.decoder:getChannelCount())
                        menu.BufferSong()
                        menu.song.queueableSource:play()
                    end
                end
            end
        else
            
        end
    end


    return menu
end
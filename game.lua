-- Queuing music to queueable source copied from love2d.org/wiki/Decoder and edited to purpose

function ReturnGame(song)
    local game = {}
    print("making game")


    game.Init = function ()
        if song == nil then
            game.song = {}
            game.song.decoder = love.sound.newDecoder("assets/songs/Alright/song.wav")
            game.song.queueableSource = love.audio.newQueueableSource(game.song.decoder:getSampleRate(), game.song.decoder:getBitDepth(), game.song.decoder:getChannelCount())
        else
            game.song = {}
            game.song.decoder = love.sound.newDecoder(song)
            game.song.queueableSource = love.audio.newQueueableSource(game.song.decoder:getSampleRate(), game.song.decoder:getBitDepth(), game.song.decoder:getChannelCount())
        end
        game.StartSong()
    end


    game.BufferSong = function ()
        local freeBufferCount = game.song.queueableSource:getFreeBufferCount()
        for i = 1, freeBufferCount do
            local soundData = game.song.decoder:decode()
            game.song.queueableSource:queue(soundData)
        end
    end

    game.StartSong = function ()
        game.BufferSong()
        game.song.queueableSource:play()
    end

    game.Update = function ()
        game.BufferSong()
    end

    game.Render = function ()
        local up, down, left, right = textures.buttons.up, textures.buttons.down, textures.buttons.left, textures.buttons.right
        local up_pos, down_pos, left_pos, right_pos = button_positions.up, button_positions.down, button_positions.left, button_positions.right
        local zoom = 5


        love.graphics.draw(up, up_pos.x, up_pos.y, 0, zoom, zoom, up:getWidth()/2,up:getHeight()/2)
        love.graphics.draw(down, down_pos.x, down_pos.y, 0, zoom, zoom, down:getWidth()/2,down:getHeight()/2)
        love.graphics.draw(left, left_pos.x, left_pos.y, 0, zoom, zoom, left:getWidth()/2,left:getHeight()/2)
        love.graphics.draw(right, right_pos.x, right_pos.y, 0, zoom, zoom, right:getWidth()/2,right:getHeight()/2)
    end

    return game
end

_G.love = require("love")
_G.vector = require("libs.vector.vector")
_G.colour = require("libs.vector.colour")
_G.game_gen = require("game")
_G.menu_gen = require("menu")
_G.background_gen = require("background")
_G.foreground_gen = require("foreground")
_G.tween = require("tween")
_G.load = require("load")
_G.controls = require("controls")

function love.load()


    -- Display somehting for the screen while the user waits for the game to load
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.setColor(0,0,0,1)
    _G.opacity_loading_screen = 1
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    _G.LIGHT_FONT = love.graphics.newFont("assets/font/Fredoka/static/Fredoka_SemiExpanded-Light.ttf", 48)
    love.graphics.setColor(1,1,1,1)
    love.graphics.print("Loading...", LIGHT_FONT, 20,10)
    love.graphics.present()


    -- Start loading the game
    Initialise()



end

function love.update(dt)
    
    -- Only if loading in decrease opacity of loading screen
    if opacity_loading_screen > 0 then opacity_loading_screen = opacity_loading_screen - dt end

    if menu.current_scene == "main" or menu.current_scene == "settings" or menu.current_scene == "you won" or menu.current_scene == "game over" then
        menu.Navigate()
        menu.Update()
    elseif menu.transition_finished == false then
        _G.game = ReturnGame(menu.song)
        game.Init()
        menu.last_game.highest_streak = 0
        menu.transition_finished = true
    else
        game.Update(dt)

        if not game.song_started and love.timer.getTime() >= (game.time_started+3) then
            game.StartSong()
        end

        if menu.transition_finished == true then
            if game.song_started and not game.song.queueableSource:isPlaying() then
                print("stopping")
                game.song.queueableSource:stop()
                menu.current_scene = "you won"
                menu.last_game.score = game.score
                game = {}
                menu.transition_finished = false
            end
        end

        if menu.transition_finished == true then
            if game and game.player_health <= 0 then
                game.song.queueableSource:stop()
                menu.current_scene = "game over"
                menu.last_game.score = game.score
                game = {}
                menu.transition_finished = false
            end
        end
    end


    -- Clear key_presses_frame of inputs at end of frame
    _G.key_presses_frame = {}
end

function love.draw()
    -- Testing


    if menu.current_scene == "main" or menu.current_scene == "settings" or menu.current_scene == "you won" or menu.current_scene == "game over" or menu.transition_finished == false then
        menu.Render()
    else
        game.Render()
        love.graphics.print(game.perfect_streak, 0, 0, 0)
        love.graphics.print(game.score, 0, 20, 0)
        love.graphics.print(game.player_health, 0, 40, 0)
    end

    --love.graphics.print(math.floor(love.timer.getTime()), 0, 0, 0) --DEBUG


    if opacity_loading_screen > 0 then
        love.graphics.setColor(0,0,0,opacity_loading_screen)
        love.graphics.rectangle("fill", 0, 0, RES.x, RES.y)
        love.graphics.setColor(menu.song.average_colour:unpack())
    end
end

function love.resize(w, h)
    _G.RES = vector.new(w,h) -- New resolution of screen in a vector
    UpdateButtonPositions()
end

_G.UpdateButtonPositions = function()
    local quart_smallest_res = (math.min(RES.x,RES.y))/4
    local half_res = RES/2
    _G.button_positions = {}
    
    button_positions.up = vector.new(half_res.x,half_res.y - quart_smallest_res)
    button_positions.down = vector.new(half_res.x,half_res.y + quart_smallest_res)
    button_positions.left = vector.new(half_res.x - quart_smallest_res,half_res.y)
    button_positions.right = vector.new(half_res.x + quart_smallest_res,half_res.y)
end
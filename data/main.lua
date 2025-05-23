-- Love2d main loop script

config = require("conf")
engine = require("engine.engine")
flux = require("packages.flux") -- This works and doesn't crash if packaged as a .love file
push = require("packages.push") -- For resolution bullshit

local gameWidth, gameHeight = 1920, 1080 --fixed game resolution
vwidth, vheight = gameWidth, gameHeight
windowWidth, windowHeight = love.window.getDesktopDimensions()

-- Runs on program start. Load game data.
function love.load()
    --push:setupScreen(gameWidth, gameHeight, windowWidth, windowHeight, {resizable=true,streched=true})
    push:setupScreen(gameWidth, gameHeight, windowWidth, windowHeight, {fullscreen = true})
    --love.resize(1920,1080)
    engine.restart_game()
end

local function draw_love_graphics()
    if state.love_draw_functions ~= nil then
        for _, func in ipairs(state.love_draw_functions) do
            love.graphics.push()  -- Save the current transformation matrix before calling the function
            func()                -- Run the custom drawing function (e.g., text)
            love.graphics.pop()   -- Restore the previous transformation matrix after the function
        end
    end
end

local function draw_characters()
    if state.sprites_to_draw == nil then 
        return
    end

    for _, sprite in ipairs(state.sprites_to_draw) do
        sprite:Draw()
    end
end

function love.draw()
    push:start()
    draw_characters()
    draw_love_graphics()
    if config.show_fps then 
        engine.show_fps()
    end
    push:finish()
end

-- Call each function in state.updaters (used for all sorts of detections)
local function call_updaters(dt)
    if state.updaters ~= nil then
        for _, func in ipairs(state.updaters) do
            func(dt)
        end
    end
end

-- Runs each frame. Used to update states.
function love.update(dt)
    flux.update(dt) -- Needed to use flux
    call_updaters(dt)
    engine.coroutine_manager(dt) -- Update all routines in state
end

-- Runs when any key is pressed.
function love.keypressed(k)

    -- Temporary code to make it easier to test stuff
	if k == 'escape' then
		love.event.push('quit')
    elseif k == 'backspace' then
        love.event.quit( "restart" )
    elseif k == "space" then
        love.load() -- Internally reset the game state (faster than restarting love, ignores changes to engine)
	end

end

function love.resize(w,h)
    return push:resize(w, h)
end

-- Runs when any ascii key is pressed. Ignores shift so you can type caps & symbols.
function love.textinput(text)
end



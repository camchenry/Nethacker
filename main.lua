-- libraries
class = require 'lib.middleclass'
vector = require 'lib.vector'
state = require 'lib.state'
tween = require 'lib.tween'
serialize = require 'lib.ser'
signal = require 'lib.signal'
hashids = require 'lib.hashids'
shine = require 'lib.shine'
require 'lib.util'

-- gamestates
require 'states.menu'
require 'states.game'
require 'states.options'

-- entities
require 'entities.sound'

-- ui
require 'lib.ui.button'
require 'lib.ui.checkbox'
require 'lib.ui.input'
require 'lib.ui.list'
require 'lib.ui.slider'

function love.load()
	love.window.setTitle(config.windowTitle)
    love.window.setIcon(love.image.newImageData(config.windowIcon))
	love.graphics.setDefaultFilter(config.filterModeMin, config.filterModeMax)
    love.graphics.setFont(font[16])

    state.registerEvents()
    state.switch(menu)

    math.randomseed(os.time()/10)

    -- Sound is instantiated before the game because it observes things beyond the game scope
    soundManager = Sound:new()

    if not love.filesystem.exists(options.file) then
        options:save(options:getDefaultConfig())
    end

    options:load()
end

function love.keypressed(key, code)
    if key == "escape" then
        love.event.quit()
    end
end

function love.mousepressed(x, y, mbutton)
    
end

function love.textinput(text)

end

function love.resize(w, h)

end

function love.update(dt)
    tween.update(dt)
end

function love.draw()

end
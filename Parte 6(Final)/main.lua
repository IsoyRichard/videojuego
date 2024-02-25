love.graphics.setDefaultFilter("nearest", "nearest")
local Player = require("player")
local Coin = require("coin")
local GUI = require("gui")
local Spike = require("spike")
local Stone = require("stone")
local Camera = require("camera")
local Enemy = require("enemy")
local Map = require("map")
local menuengine = require("menuengine")
local mainmenu
local gameStarted = false
local gameBird = false

push = require 'Libraries/push'
Class = require 'Libraries/class'

require 'Classes/Bird'
require 'Classes/Pipe'
require 'Classes/PipePair'
require 'Classes/StateMachine'

require 'States/BaseState'
require 'States/PlayState'
require 'States/TitleState'
require 'States/CountDownState'
require 'States/EndState'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 512
VIRTUAL_HEIGHT = 288

local background_bird = love.graphics.newImage('Images/background.png')
local ground = love.graphics.newImage('Images/ground.png')

backgroundScroll = 0
groundScroll = 0
backgroundSpeed = 100
groundSpeed = 200
BACKGROUND_LOOPING_POINT = 413

PIPE_GAP = 80
PIPE_PAIR_LOWER_LIMIT = 40
PIPE_PAIR_UPPER_LIMIT = 155
GRAVITY = 20
JUMP_VELOCITY = 500

score = 0
scrolling = true

function startgamebird()
	gameBird = true
end

function startgame()
	gameStarted = true
end




function love.load()
	Enemy.loadAssets()
	Map:load()
	background = love.graphics.newImage("assets/background.png")
	GUI:load()
	Player:load()


	love.window.setMode(1280, 720)
	love.graphics.setFont(love.graphics.newFont(30))
	mainmenu = menuengine.new(500, 250)
	mainmenu:addEntry("Escoja un juego")
	mainmenu:addSep()
	mainmenu:addEntry("Platform Game",startgame)
	mainmenu:addEntry("Pixelated Flight",startgamebird)
	mainmenu:addEntry("Salir", love.event.quit)




    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
		vsync = true,
		fullscreen = false,
		resizable = true
	})

	smallFont = love.graphics.newFont('Fonts/font.ttf', 8)
	mediumFont = love.graphics.newFont('Fonts/font.ttf', 16)
	largeFont = love.graphics.newFont('Fonts/font.ttf', 64)

	love.graphics.setFont(largeFont)

	stateMachine = StateMachine {
		['play'] = function() return PlayState() end,
		['title'] = function() return TitleState() end,
		['countdown'] = function() return CountDownState() end,
		['end'] = function() return EndState() end
	}

	stateMachine:change('title')

	love.keyboard.keysPressed = {}

end

function love.resize(w, h)
    push:resize(w, h)

end




function love.update(dt)
	if gameStarted then
		World:update(dt)
		Player:update(dt)
		Coin.updateAll(dt)
		Spike.updateAll(dt)
		Stone.updateAll(dt)
		Enemy.updateAll(dt)
		GUI:update(dt)
		Camera:setPosition(Player.x, 0)
		Map:update(dt)
	elseif gameBird then
		backgroundScroll = (backgroundScroll + backgroundSpeed * dt) % BACKGROUND_LOOPING_POINT
		groundScroll = (groundScroll + groundSpeed * dt) % VIRTUAL_WIDTH
		stateMachine:update(dt)
		love.keyboard.keysPressed = {}
	else
		mainmenu:update()
	end
end

function love.draw()
	if gameStarted then
		love.graphics.draw(background)
		Map.level:draw(-Camera.x, -Camera.y, Camera.scale, Camera.scale)
		Camera:apply()
		Player:draw()
		Enemy.drawAll()
		Coin.drawAll()
		Spike.drawAll()
		Stone.drawAll()
		Camera:clear()
		GUI:draw()
	elseif gameBird then
		push:start()
		love.graphics.draw(background_bird, -backgroundScroll, 0)
		stateMachine:render()
		love.graphics.draw(ground, -groundScroll, VIRTUAL_HEIGHT - 16)
		push:finish()
	else
		love.graphics.clear()
		mainmenu:draw()
	end
end

function love.keypressed(key)
	love.keyboard.keysPressed[key] = true
	Player:jump(key)
end

function love.keyboard.wasPressed(key)
    return love.keyboard.keysPressed[key]

end

function beginContact(a, b, collision)
	if Coin.beginContact(a, b, collision) then return end
	if Spike.beginContact(a, b, collision) then return end
	Enemy.beginContact(a, b, collision)
	Player:beginContact(a, b, collision)
end

function endContact(a, b, collision)
	Player:endContact(a, b, collision)
end


function love.mousemoved(x, y, dx, dy, istouch)
	menuengine.mousemoved(x, y)
end
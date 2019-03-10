
Gamestate = require "hump.gamestate"
Timer = require "hump.timer"
Camera = require "hump.camera"

local graphicOne = {}
local graphicTwo = {}
local graphicThree = {}
local graphicFour = {}

local height = love.graphics.getHeight()
local width = love.graphics.getWidth()

function flipNegativeSign(input)
  if input < 0 then
    return input * -1
  end
  return input
end

function rgb(red, green, blue)
  local colorTable = {}
  table.insert(colorTable, red / 255)
  table.insert(colorTable, green / 255)
  table.insert(colorTable, blue / 255)
  return colorTable
end

function love.load()

  -- Start program timers
  startTime = love.timer.getTime()

  -- Load the recording device https://love2d.org/wiki/RecordingDevice
  devices = love.audio.getRecordingDevices( )
  recordingDevice = devices[1]

  -- device infomation
  local deviceName = recordingDevice:getName()
  local samplecount = recordingDevice:getSampleCount()
  local samplerate = recordingDevice:getSampleRate()
  local bitdepth = recordingDevice:getBitDepth()
  local channels = recordingDevice:getChannelCount()

  -- initiate the recording device
  if recordingDevice then

    source = love.audio.newQueueableSource( samplerate, bitdepth, channels )
    recordingDevice:start()

    -- load first graphic state
    Gamestate.registerEvents()
    Gamestate.switch(graphicOne)
  end

  function love.keypressed(key)
    if key == "up" then
      if Gamestate.current() == graphicOne then return Gamestate.switch(graphicTwo) end
      if Gamestate.current() == graphicTwo then return Gamestate.switch(graphicThree) end
      if Gamestate.current() == graphicThree then return Gamestate.switch(graphicFour) end
      if Gamestate.current() == graphicFour then return Gamestate.switch(graphicOne) end
    end
  end

  function queueData()
    local minsamples = 1
    if recordingDevice:isRecording( ) and recordingDevice:getSampleCount( ) > minsamples then
  	  data = recordingDevice:getData( )
  	  source:queue( data )
    end
  end

  -- load logos and images
  logo = love.graphics.newImage("/assets/LIG - thintext - smaller.png")


end

-- GraphicOne : WaterFall
-- plots a line with the thickness assigned by
-- recordingDevice:getData()
-- @DESIGN
-- Duo colours
-- neutral background
-- @SONG
-- Ticking

function graphicOne:update( dt )

  queueData()

end

function graphicOne:draw()
  if data then
    sliceWidth = width * 1.0 / data:getSampleCount()
    x = 0

    for count = 1, data:getSampleCount() - 1 do
      local velocity = data:getSample( count )
      local y = velocity * height / 2

      love.graphics.setColor(1, 0.6, 0.6, 0.3)
      love.graphics.rectangle("line", 0, height / 2, y * x, y * 2)

      love.graphics.setColor(1, 1, 1, 0.9)
      love.graphics.line(0, height / 2, y * x, x)
      love.graphics.line(x, height / 2, y * 2, 0)

      love.graphics.setColor(1, 1, 1, 0.3)
      love.graphics.line(y * 3, x * 3, x * 3, y * 3)

      love.graphics.setColor(1, 0.6, 0.6, 0.85)
      love.graphics.rectangle("fill", x * 2, y, 7, 7)
      love.graphics.rectangle("fill", y, x * 2, 7, 7)
      love.graphics.rectangle("fill", y, x * 2, 7, 7)


      x = x + sliceWidth
    end
  end
end

-- GraphicTwo : Sparkling Stars
-- plots random points onto the canvas
-- holds each one for a second
-- and their size is determined by
-- data:getSample(at current index)
-- @DESIGN
-- Colourful - large pallette, each point
-- a seperate colour, Primary colours.
-- neutral background
-- @SONG
-- Colour

function graphicTwo:enter()

  runTimer = Timer.new()
  pointX =  math.random(0, width)
  pointY = math.random(0, height)

  runTimer:every(0.001, function()
      pointX =  math.random(0, width)
      pointY = math.random(0, height)
    end)

end

function graphicTwo:update(dt)

  queueData()
  runTimer:update(dt)

end

function graphicTwo:draw()

  love.graphics.setBackgroundColor(0.1, 0.1, 0.1, 0)
  
  if data then
    -- logo image
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(
      logo,
      width / 2 ,
      height / 2,
      data:getSample(1),
      1, 1,
      logo:getWidth() / 2,
      logo:getHeight() / 2
    )

    for count = 1, data:getSampleCount() - 1 do

      love.graphics.setColor(1, 1, 1)
      love.graphics.setPointSize(data:getSample(count) * 500)
      love.graphics.points(pointX , pointY)

    end
  end
end

function graphicTwo:leave()
  runTimer:clear()
end

-- GraphicThree : Wavey Points
-- plots uniform points across the center
-- of the canvas
-- and their size is determined by
-- data:getSample(at current index)
-- @DESIGN
-- coloured points
-- neutral background
-- @SONG
-- Echoes

function graphicThree:enter()
  gold = rgb(212, 175, 55)
  darkRed = rgb(125, 10, 2)
end

function graphicThree:update( dt )

  queueData()

end

function graphicThree:draw()

  love.graphics.setBackgroundColor(0.1, 0.1, 0.1, 0)

  -- darkRed stripe
  love.graphics.setColor(darkRed[1], darkRed[2], darkRed[3])
  love.graphics.rectangle("fill", 0, height / 2 - 200, width, 400)

  -- gold stripe
  love.graphics.setColor(gold[1], gold[2], gold[3])
  love.graphics.rectangle("fill", 0, height / 2 - 100, width, 200)

  -- black stripe
  love.graphics.setColor(0.1, 0.1, 0.1)
  love.graphics.rectangle("fill", 0, height / 2 - 50, width, 100)

  if data then

    -- logo image
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(
      logo,
      width / 2 ,
      height / 2,
      data:getSample(1),
      1, 1,
      logo:getWidth() / 2,
      logo:getHeight() / 2
    )

    local spread = width / data:getSampleCount()
    local currentPoint = 0

    for i = 1, data:getSampleCount() - 1 do
      love.graphics.setColor(1, 1, 1)
      love.graphics.setPointSize(data:getSample( i ) * 500)
      love.graphics.points(
        currentPoint,
        height / 2,
        currentPoint,
        height * data:getSample(i) * spread
      )

      currentPoint = currentPoint + spread
    end

    currentPoint = 0
  end
end

-- GraphicFour : Tweening
-- Tweens shapes using getSample()
-- @DESIGN
-- possible graphics or PNGs?
-- @SONG
-- PiffWang

function graphicFour:enter()

  -- repeated tweening
  runTimer = Timer.new()
  view = Camera(width / 2, height / 2)
  circle = {rad = 10, x = 100, y = 100}
  local grow, shrink, move_down, move_up

  grow = function()
      Timer.tween(1, circle, {rad = 50}, 'in-out-quad', shrink)
  end
  shrink = function()
      Timer.tween(2, circle, {rad = 10}, 'in-out-quad', grow)
  end
  move_down = function()
      Timer.tween(3, circle, {x = 700, y = 500}, 'bounce', move_up)
  end
  move_up = function()
      Timer.tween(5, circle, {x = 200, y = 200}, 'out-elastic', move_down)
  end

  grow()
  move_down()

  runTimer:every(0.5, function()
    love.graphics.setColor(math.random(), math.random(), math.random())
  end)

end

function graphicFour:update(dt)

    queueData()
    Timer.update(dt)
    runTimer:update(dt)

  if data then
    for i = 1, data:getSampleCount() - 1 do
      view:zoomTo(data:getSample(i) * 50)
    end
  end

end

function graphicFour:draw()
  view:attach()
  love.graphics.setBackgroundColor(0.1, 0.1, 0.1)

  love.graphics.circle('fill', circle.x, circle.y, circle.rad)
  love.graphics.circle('fill', circle.x * 2, circle.y * 2, circle.rad * 2)
  love.graphics.circle('fill', circle.x / 2, circle.y / 2, circle.rad / 2)

  love.graphics.circle('fill', circle.x * 20, circle.y * 20, circle.rad * 20)
  love.graphics.circle('fill', circle.x / 20, circle.y / 20, circle.rad / 20)

  love.graphics.circle('fill', circle.y, circle.x, circle.rad)
  love.graphics.circle('fill', circle.y * 2, circle.x * 2, circle.rad * 2)
  love.graphics.circle('fill', circle.y / 2, circle.x / 2, circle.rad / 2)

  love.graphics.circle('fill', circle.y * 20, circle.x * 20, circle.rad * 20)
  love.graphics.circle('fill', circle.y / 20, circle.x / 20, circle.rad / 20)
  view:detach()
end

function graphicFour:leave()
  runTimer:clear()
end

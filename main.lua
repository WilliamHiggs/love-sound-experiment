
Gamestate = require "hump.gamestate"

local graphicOne = {}
local graphicTwo = {}
local height = love.graphics.getHeight()
local width = love.graphics.getWidth()

function flipNegativeSign(input)
  if input < 0 then
    return input * -1
  end
  return input
end

function love.load( )

  -- load first graphic state
  Gamestate.registerEvents()
  Gamestate.switch(graphicTwo)

  -- Load the recording device https://love2d.org/wiki/RecordingDevice
  devices = love.audio.getRecordingDevices( )
  recordingDevice = devices[1]

  -- device infomation
  deviceName = recordingDevice:getName()
  samplecount = recordingDevice:getSampleCount()
  samplerate = recordingDevice:getSampleRate()
  bitdepth = recordingDevice:getBitDepth()
  channels = recordingDevice:getChannelCount()
  minsamples = 1

  -- initiate the recording device
  if recordingDevice then
    source = love.audio.newQueueableSource( samplerate, bitdepth, channels )
    recordingDevice:start()
  end

  function queueData()
    if recordingDevice:isRecording( ) and recordingDevice:getSampleCount( ) > minsamples then
  	  data = recordingDevice:getData( )
  	  source:queue( data )
    end
  end

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

  sliceWidth = width * 1.0 / data:getSampleCount()
  x = 0

  for count = 1, data:getSampleCount( ) - 1 do
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

function graphicTwo:update( dt )

  queueData()

end

function graphicTwo:draw()

  for count = 1, data:getSampleCount() - 1 do
    local pointX =  math.random(0, width)
    local pointY = math.random(0, height)

    pointSize = love.graphics.getPointSize() + data:getSample(count)
    love.graphics.setPointSize( pointSize )
    love.graphics.points(pointX, pointY)

  end
  pointSize = 0
end

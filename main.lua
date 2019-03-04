
Gamestate = require "hump.gamestate"

local graphicOne = {}
local height = love.graphics.getHeight()
local width = love.graphics.getWidth()

function love.load( )

  -- load first graphic state
  Gamestate.registerEvents()
  Gamestate.switch(graphicOne)

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

  x = 0

end

function graphicOne:update( dt )

  if recordingDevice:isRecording( ) and recordingDevice:getSampleCount( ) > minsamples then
	  data = recordingDevice:getData( )
	  source:queue( data )
  end

end

function graphicOne:draw()

  sliceWidth = width * 1.0 / data:getSampleCount()
  dataPoints = {}
  x = 0

  for count = 1, data:getSampleCount( ) - 1 do
    local velocity = data:getSample( count ) --/ data:getSampleCount( )
    local y = velocity * height / 2



    love.graphics.rectangle("fill", 0, height / 2, width, y)

    love.graphics.line(0, height / 2, y * 2, x)
    love.graphics.line(y,x,x,y)

    x = x + sliceWidth

  end



  love.graphics.rectangle("fill", 0, height / 2, width, 1)

end

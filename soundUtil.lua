local soundUtil = {}

function soundUtil.peakAmplitude(sounddata)
  local peak_amp = - math.huge
  for t = 0, sounddata:getSampleCount() - 1 do
    local amp = math.abs(sounddata:getSample(t)) -- |s(t)|
    peak_amp = math.max(peak_amp, amp)
  end
  return peak_amp
end

function soundUtil.rmsAmplitude(sounddata)
  local amp = 0
  for t = 0,sounddata:getSampleCount() - 1 do
    amp = amp + sounddata:getSample(t)^2 -- (s(t))^2
  end
  return math.sqrt(amp / sounddata:getSampleCount())
end

return soundUtil

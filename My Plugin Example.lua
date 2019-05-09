PluginInfo = 
{
  Name = "My Super Plugin v5.0",
  Version = "5.0",
  Id = "c2b08142-0435-48d8-b639-caad0cf9c0d4",
  Description = "Plugin Example featuring the latest features in QSD 5.0",
  ShowDebug = true
}

-- optional
function GetPrettyName(props)
  return "My Super Plugin v5.0 with "..props["Input Count"].Value.." inputs"
end

function GetColor(props)
  return { 240, 0, 240 }
end


function GetProperties() 
  props = {}
  table.insert( props, 
  {
    Name = "Input Count",
    Type = "integer",
    Min = 0,
    Max = 128,
    Value = 8,
  })
  
  for i = 1, 10 do
    table.insert( props, 
    {
      Name = string.format("Is really cool %i", i),
      Type = "boolean",
      Value = true,
    });
  end
  return props
end

-- ControlType can be Button, Knob, Indicator or Text
-- ButtonType ( ControlType == Button ) can be Momentary, Toggle or Mute
-- IndicatorType ( ControlType == Indicator ) can be Led, Meter, Text or Status
-- ControlUnit ( ControlType == Knob ) can be Hz, Float, Integer, Pan, Percent, Position or Seconds
function GetControls(props)
  return 
  {
    {
      Name = "inputgain", -- single word name chosen for simplicity in the runtime script
      ControlType = "Knob",
      ControlUnit = "dB",
      Min = -6,
      Max = 6,
      Count = props["Input Count"].Value,
      PinStyle = "Both",
      UserPin = true -- UserPin allows pin choice to be added to the Control Pins section of the Properties
    },
    {
      Name = "Mute",
      ControlType = "Button",
      ButtonType = "Toggle",
      Count = 1,
      PinStyle = "Output",
      UserPin = false, -- No UserPin or UserPin=false with PinStyle means the pin is present with no option to remove it
    },
   }
,
      ZOrder = 1end
function GetControlLayout(props)
  -- make input gains
  layout = {}
  
  local i_count = props["Input Count"].Value
  for i=1,i_count do 
    layout["inputgain"..tostring(i_count==1 and "" or " "..i)] =   -- multiple controls are indexed with a space and the index
    {
      PrettyName = string.format("Input Gain~%i",i), -- The Tilde (~) creates a folder break for the Control Pin list
      Style = "Fader",
      Color = { 128, 255*(i-1)/i_count, 128 },
      Position = { 10+32*(i-1), 115 },
      Size = { 32, 128 },
      IsReadOnly = i == 3,
      ZOrder = 6 + i
    }
  end
  layout["Mute"] = 
  {
    Legend = "MUTE ME",
    IsBold = true,
    TextFontSize = 20,
    Color = { 255, 0, 0 },
    Margin = 0,
    Radius = 0,
    Position = { 10, 58 },
    Size = { 32*i_count, 32 },
    UnlinkOffColor = true,
    OffColor = { 0, 255, 128 },
    ZOrder = 5
  }
  
  graphics = 
  {
    {
      Type = "GroupBox",
      Text = "A blue Groupbox for our control panel",
      HTextAlign = "Left",
      IsBold = true,
      Fill = { 191, 226, 249 },
      StrokeColor = { 0, 0, 0 },
      StrokeWidth = 1,
      CornerRadius = 8,
      Position = { 0, 0 },
      Size = { 20+32*i_count, 264 },
      ZOrder = 1
    },
    {
      Type = "Label",
      Text = "Woohoo Label",
      TextSize = 24,
      IsBold = true,
      Color = { 0, 255, 0 },
      Fill = { 0, 123, 222 },
      StrokeColor = { 255, 0, 255 },
      StrokeWidth = 6,
      CornerRadius = 15,
      Position = { 10, 26 },
      Size = { 32*i_count, 32 },
      ZOrder = 2
    },
    {
      Type = "Header",
      Text = "Input Faders",
      Position = { 10, 97 },
      Size = { 32*i_count, 17 },
      ZOrder = 3
    },
  }
  if i_count>2 then
    table.insert(graphics,
    {
      Type = "Label",
      Text = "Disabled Control",
      TextSize = 8,
      Position = { 74, 243 },
      Size = { 32, 21 },
      ZOrder = 4
    })
  end
  return layout, graphics
end

function GetPins(props)
  local pins = {}
  for i = 1,props["Input Count"].Value do
    table.insert(pins,
    {
      Name = string.format("Input %i", i),
      Direction = "input",
    })
  end
  table.insert(pins,
  {
    Name = "Mix Output",
    Direction = "output",
  })
  
  table.insert( pins, { Name = "sub in", Direction = "input"})
  table.insert( pins, { Name = "sub out", Direction = "output"})
  table.insert( pins, { Name = "a", Direction = "output"})
  table.insert( pins, { Name = "c", Direction = "output"})
  table.insert( pins, { Name = "b", Direction = "output"})
  
  table.insert( pins, { Name = "input", Direction = "input", Domain = "serial" } )
  return pins
end

function GetComponents(props)
  return 
  { 
    {   
      Name = "main_mixer",
      Type = "mixer", 
      Properties =   
      {
        ["n_inputs"] = props["Input Count"].Value, -- discover these property names using Named Component Lister
        ["n_outputs"] = 1,                         -- Only set the non-default values you need
      }
    }
  }
end

function GetWiring(props)
  local wiring = {}
  for i = 1, props["Input Count"].Value do
    table.insert( wiring, { string.format("Input %i", i), string.format("main_mixer Input %i", i) } )
  end
  table.insert( wiring, { "Mix Output", "main_mixer Output 1" } )
  table.insert( wiring, { "sub in", "sub out" } )
  return wiring
end

-- Controls only exist when plugin is actually running
-- we don't want to run this code during initialization 
-- and property editing
if Controls then -- Start of runtime Lua code

local outputGain = main_mixer["output.1.gain"]
local outputMute = main_mixer["output.1.mute"]

-- set crosspoint gains to be 0
for i = 1,#Controls.inputgain do
  main_mixer[string.format("input.%i.output.1.gain",i)].Value = 0
end

Controls.Mute.EventHandler= function( ctl ) 
  print( "setting mute to ".. ctl.Value )
  outputMute.Value = ctl.Value
  if ser then 
    ser:Write(string.sub(data, idata, idata))
    idata = idata + 1
    if idata > #data then idata = 1 end  
  end
end

-- yet another worthless average function...
function av()
  local sum = 0
  for k,v in ipairs( Controls.inputgain ) do
    sum = sum + v.Value
  end
  local average = sum /  #Controls.inputgain
  print("setting output to "..average)
  outputGain.Value = average
end

for k,v in ipairs( Controls.inputgain ) do v.EventHandler = av end


end -- end of runtime Lua code





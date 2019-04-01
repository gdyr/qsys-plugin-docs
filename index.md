# Q-SYS Plugin "Documentation"
**Version:** 7.0v2  
**Date:** 02-16-2017

Changes since last update (5.3 release):
- Added `GetPages()` function which works with the page_index to spread layouts across multiple pages
- added `FontSize` to plugins which bypasses autoscaling of old font property sizes to 90% in 7.0
- added `Padding`, `StrokeColor` and `StrokeWidth` to controls in plugins
- added `Font` and `FontStyle` to graphics and controls

## File Extensions
Plugins can have either:
- `.lua*`
- `.qplug`

The reason for the `*` after `.lua` is that adding extra characters after `.lua` won't hide the file from Q-SYS.  
To Q-SYS, `example.lua` is just as visible as `example.luaold`. Using something like `example.lua.old` will result in hiding the file from Q-SYS.

## File Sections

### PluginInfo

```lua
PluginInfo = 
{
  Name = "My Folder~Plugin Name",                 -- Appears in the Schematic Library (in "My Folder").
  Version = "1.0.0",                              -- A version number string - to detect version mismatches.
  Id = "0c02812a-8c75-4867-af91-06c11ee59bce",    -- A unique hyphenated GUID (guidgenerator.com)
  Description = "Includes some bugfixes",         -- this message is seen when a version mismatch occurs
  ShowDebug = false                               -- shows the Lua debug window at the bottom of the UI
}
```

### Block color:
```lua
function GetColor(props)
  return { 0, 255, 0 }    -- R, G, B
end
```

### Pretty Name
```lua
function GetPrettyName(props)
  return "The best litle Plugin in Texas" <-- to define a longer component name than the library name
end
```

### Properties
  Each property can have:
  - Name = string (text displayed next to property and referred to as `props["<property_name>"].Value` in the code)
  - Type = string, integer, double, boolean, enum (boolean will give Yes or No choice, but true/false in the code)
  - Value = default value for property (in correct type for property)
  - for enum type: `Choices = { list of choice strings }` for ComboBox
  - for integer or double types: 
    Min = lowest extent
    Max = highest extent
```lua
function GetProperties()
  return
  {
    {
      Name = "Pick a number",
      Type = "integer",
      Min  = 1,
      Max = 100,
      Value = 1
    },
    {
      Name = "Best Way to Go",
      Type = "enum",
      Choices = { "This way", "That way" },
      Value = "This way",
    },
  }
end
```

When properties need to change based on the property values, the `RectifyProperties` function can be used:
```lua
function RectifyProperties(props)
  -- example: hide "Number of PINs" if "Use Pins" is "No"
  props["Number of PINs"].IsHidden = props["Use PIN"].Value == "No"
  return props
end
```

### Controls
```lua
function GetControls(props)

  return {

    {
      Name = "Input Gain",  -- Name used for control, on pins and via Lua Scripts and QRC
      ControlType = "Knob", -- Can be Button, Knob, Indicator or Text
      ControlUnit = "dB",   -- For Knob: Hz, Float, Integer, Pan, Percent, Position or Seconds
      Min = -6,   -- minimum value for knob
      Max = 6,    -- maximum value for knob
      Count = 10, -- number of controls to create (can be calculated based on properties, etc.)
    },

    {
      Name = "Mute",
      ControlType = "Button",
      ButtonType = "Toggle", -- ButtonType: Momentary, Toggle or Trigger
      UserPin = boolean      -- If true, pin will be available in Control Pins area
      PinStyle = "Input",    -- PinStyle can be "Input", "Output", "Both"
      IconType = "SVG",      -- Can be "SVG" "Image" or "Icon"(default)
      Icon = "base64-encoded svg data (svg, png, jpg)" -- for IconType "SVG"
      -- or
      Icon = "base64-encoded image data (png, jpg)" -- for IconType "Image"
      -- or
      Icon = "name of built-in icon e.g. skull" -- for IconType "Icon"
    },

    {
      Name = "My Eight LEDs",
      ControlType = "Indicator",
      PinStyle = "Output",
      IndicatorType = "Led", -- IndicatorType can be Led, Meter, Text or Status
      Count = 8,
    },

   }

end
```

### Control Layout
```lua
function GetControlLayout(props)

  -- Make a local control layout table containing a list specifying
  -- details for each control defined in GetControls

  local layout = {}

  layout["Status"] =
  {
    Style = "Text",
    Position = { 114, 31 },
    Size = { 217, 19 },
    IsReadOnly = true
  }

  -- continues below

```

  Options:
  - `Position = { x, y }`
  - `Size = { h, w }`
  - `Color = { r, g, b }`
  - `UnlinkOffColor = a boolean`
  - `OffColor = { r, g, b }`
  - `BackgroundColor = { r, g, b }` (for Meters)
  - `PrettyName = "My Friendly Control"` (displayed to user, but different to what is used in the code)
  - `Style = "Fader"/"Knob"/"Button"/"Text"/"Meter"/"Led"/"ListBox"/"ComboBox"`
  - `ButtonStyle = "Toggle"/"Momentary"/"Trigger"/"On"/"Off"/"Custom"` (custom is for a String type button)
  - `CustomButtonUp = "a string"` (custom button only)
  - `CustomButtonDown = "a string"` (custom button only)
  - `MeterStyle = "Level"/"Reduction"/"Gain"/"Standard"` (meter style only)
  - `HTextAlign = "Center"/"Left"/"Right"`
  - `VTextAlign = "Center", "Top", "Bottom"`
  - `TextBoxStyle = "Normal"/"Meter"/"NoBackground"`
  - `Legend = "Button Text"` (for buttons - can be changed with runtime Lua)
  - `WordWrap = true`
  - `Padding = 10` (v7.0+)
  - `StrokeColor = { r, g, b }` (v7.0+; Default is {0,0,0}, which is black)
  - `StrokeWidth = 2` (New for 7.0; Default is 1)
  - `ShowTextbox = false` (for meters, faders and knobs)
  - `TextFontSize = 12` (deprecated - see FontSize)
  - `IsBold = true` (deprecated - see FontStyle)
  - `FontSize = 12`
  - `Font = "Montserrat"`
  - `FontStyle = "ThinItalic"` (check Designer font dropdowns for valid styles)
  - `Margin = 4`
  - `Radius = 3`
  - `CornerRadius = 2`
  - `IsReadOnly = a boolean` (not changeable at runtime, good for turning read-write controls into indicators)


### Graphics Layout
Still inside the GetControlLayout function, make a local graphics layout table containing a list specifying details for each raphic element needed in the Plugin.  
Z-Order is determined by the order graphics are defined (lower to upper; upper covers lower)

```lua
  
  -- continues from function above
  
  local graphics = {

    {
      Type = "GroupBox",
      Text = "Status",
      HTextAlign = "Left",
      StrokeWidth = 1,
      CornerRadius = 8,
      Fill = { 215, 215, 235 },
      Position = { 0, 0 },
      Size = { 345, 126 }
    },

  }

  return layout, graphics;

end

```

Options:
  - `Position = { 20, 30 }`
  - `Size = { 64, 64 }`
  - `Type = "Label"/"GroupBox"/"Header"/"MeterLegend"/"Image"/"Svg"`
  - `Image = "...data..."` (which contains the entire Base-64-encoded JPG/PNG/SVG string for the Image or Svg types)
  - `Text = "Some label or other text"`
  - `TextSize = 15` (deprecated - see FontSize)
  - `FontSize = 15`
  - `Font = "Montserrat"`
  - `FontStyle = "ThinItalic"`
  - `HTextAlign = "Center"/"Left"/"Right"`
  - `VTextAlign = "Center"/"Top"/"Bottom"`
  - `IsBold = true`
  - `Color = { r, g, b }`
  - `TextColor = { r, g, b }` (for "Label" type, use 'Color' to set the text color)
  - `StrokeColor = { r, g, b }` (for color of the outline - GroupBox and Label only)
  - `Fill = { r, g, b }` (color inside the outline - GroupBox only)
  - `StrokeWidth = 2`
  - `CornerRadius = 3`
  - `Radius = 2`

### Pages (v7.0+)
```lua
function GetPages()
  return {
    { name = "Page 1" },
    { name = "Page 2" }
  }
end
```

In `GetControlLayout()`, you can define control and/or graphics using a conditional check of the `page_index` virtual property to determine which elements appear on which page. Any elements which are not part of a conditional statement using page_index will appear on all pages. This might be useful for logos or controls which should appear in the same place on every page.

Within `GetControlLayout(props)`:
```lua
  if props['page_index'].Value==1 then
    -- controls and graphics which appear on page 1
  elseif props['page_index'].Value==2 then
    -- controls and graphics which should appear on page 2
  end

  -- controls and graphics which should appear on all pages
  -- should be outside of the page_index conditional statement
```

### Pins

```lua
function GetPins(props) <-- define Plugin pins that AREN'T tied to UI controls (internal components)
  -- The order the pins are defined determines their onscreen order
  -- This section is optional. If you don't need pins to internal components, you can omit the function

  local pins = {}
  table.insert(pins,
    {
      Name = "Audio Input",
      Direction = "input",
    })
  table.insert(pins,
    {
      Name = "Audio Output",
      Direction = "output",
    })
  table.insert(pins,
    {
      Name = "Serial",
      Direction = "input",
      Domain = "serial" <-- to add serial pins. Not needed for audio pins.
    })
  return pins
end
```

### Components
```lua
function GetComponents(props)

  -- This section is optional. If you don't need any internal components, you can omit the function

  return 
  { 
    {   
      Name = "main_mixer", -- Name which your runtime Lua code will reference this component
      Type = "mixer",      -- Type is the type obtained from the Named Components Lister
      Properties =   
      {
        ["n_inputs"] = 8,  -- define any non-default properties the component must use (Named Component Lister)
        ["n_outputs"] = 1,
      }
    }
  }

end
```

### Wiring
```lua
function GetWiring(props) 

  -- This section is optional. If you have any internal components or non-control pins, you can omit the function
  -- Wiring to multiple internal components or pins: place all pins into one longer wiring definition statement

  local wiring = {}

  for i = 1,8 do
    table.insert( wiring, { string.format("Input %i", i), string.format("main_mixer Input %i", i) } )
  end

  table.insert( wiring, { "Mix Output", "main_mixer Output 1" } )

  return wiring

end
```

### Control Script
```lua
if controls then

  -- Your runtime Lua code goes here.
  -- All Q-Sys Lua libraries and functions and are available within the Plugin environment.
  -- Access Plugin controls with "Controls." as you would in a Scriptable Control

end
```

## Misc Tips

**Tip 1:**  
If you have multiple identical components named with ascending numbers, to access those components from the runtime Lua code, you must refer to them using the Global Lua variable _G and their name:  
example: If you defined a mixer component in a loop and appended numbers to the names to keep them unique...
```lua
mixer1 = _G["mixer_1"]
print(mixer1["output.1.gain"]
-- or
mixer1gain = _G["mixer_1"]["output.1.gain"]
print(mixer1gain)
```
Basically, you can just pre-pend the _G to the usual way to address Named Components

**Tip 2:**  
Components within Plugins only have accessability from the Lua script within the Plugin. This means that you can reuse an internal component name in another Plugin within the same file or have multiple copies of the same Plugin within a file without conflict.

**Tip 3:**  
To access Plugin property values table from within the runtime Lua code, use the 'Properties' table constant
Each property name has .Name (itself), Value (what it is currently set to), Type (string, integer, double, bool, enum) and for integer type, Min and Max.
To access the value of any property, use dot notation (example of an enum property called "Model"):
```lua
if Properties.Model.Value == "Tesla Model S" then
  print("Awesome!")
elseif Properties.Model.Value == "Geo Metro" then
  print("Awww!")
end
```
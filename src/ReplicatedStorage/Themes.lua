-- Color schemes
-- Ideas from https://www.schemecolor.com/

local Themes = {
  ['CurrentTheme'] = "Light",

  -- GUI
  ['Light'] = {
    ['BorderColor'] = Color3.fromRGB(19, 153, 255),
    ['Color'] = Color3.fromRGB(206, 237, 255),
    ['InnerFrameColor'] = Color3.fromRGB(234, 252, 255),
    ['TextColor'] = Color3.fromRGB(19, 153, 255),
    ['TextColor2'] = Color3.fromRGB(14, 115, 188),
  },
  ['Dark'] = {
    ['BorderColor'] = Color3.fromRGB(48, 112, 168),
    ['Color'] = Color3.fromRGB(6, 53, 85),
    ['InnerFrameColor'] = Color3.fromRGB(5, 5, 5),
    ['TextColor'] = Color3.fromRGB(119, 200, 255),
    ['TextColor2'] = Color3.fromRGB(114, 160, 180),
  },

  -- Used for map
  ['ColorSchemes'] = {
    { -- Buttermilk / Mauve
      ['Floor'] = { R=0xfe, G=0xf3, B=0xbb },
      ['Wall'] = { R=0xe9, G=0xb2, B=0xd0 },
    },
    { -- Pastel blue / green
      ['Floor'] = { R=0xcc, G=0xff, B=0xcc },
      ['Wall'] = { R=0xaf, G=0xdd, B=0xff },
    },
    { -- Lavender
      ['Floor'] = { R=0x99, G=0x85, B=0xda },
      ['Wall'] = { R=0x8f, G=0x8f, B=0xf2 },
    },
  },
}

return Themes


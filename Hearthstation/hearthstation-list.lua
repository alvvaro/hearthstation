hsAction = {}

-- Types:
-- 0 = item/toy, 1 = spell

function hsAction:new(ID, type)

  local self = setmetatable({}, hsAction)

  self.ID = ID
  self.spell = ID
  type = type or 0
  self.type = type

  if type == 0 then --item

    self.icon = GetItemIcon(self.ID)
    __, self.spell = GetItemSpell(self.ID) --why do i need this? for tooltips only i guess
    self.mtxt = "/cast item:" .. self.ID

  elseif type == 1 then --spell

    self.mtxt, __, self.icon = GetSpellInfo(self.ID)
    self.mtxt = "/cast " .. self.mtxt

  end

  return self

end

-- LIST

  hsHST = hsAction:new(6948)  -- Hearthstone

hsItemTable = {

  GHS = hsAction:new(110560), -- Garrison Hearthstone
  DHS = hsAction:new(140192), -- Dalaran Hearthstone
  WHS = hsAction:new(141605), -- Whistle

}

hsCovenantTable = {

  CKY = hsAction:new(184353), -- Kyrian Hearthstone 1
  CVT = hsAction:new(183716), -- Venthyr Hearthstone 2
  CNF = hsAction:new(180290), -- Night Fae Hearthstone 3
  CNL = hsAction:new(182773), -- Necrolord Hearthstone 4

}

hsToyTable = {

  ETH = hsAction:new(172179), -- Eternal Traveler's Hearthstone
  IKD = hsAction:new(64488),  -- Innkeeper's Daughter Toy
  HDH = hsAction:new(168907), -- Holographic Digitalization Hearthstone
  BRH = hsAction:new(166747), -- Brewfest Reveler's Hearthstone
  NGH = hsAction:new(165802), -- Noble Gardener's Hearthstone
  PLH = hsAction:new(165670), -- Peddlefeet's Lovely Hearthstone
  LEH = hsAction:new(165669), -- Lunar Elder's Hearthstone
  FEH = hsAction:new(166746), -- Fire Eater's Hearthstone
  HHH = hsAction:new(163045), -- Headless Horseman's Hearthstone
  GWH = hsAction:new(162973), -- Greatfather Winter's Hearthstone
  TTP = hsAction:new(142542), -- Tome of Town Portal
  ETP = hsAction:new(54452),  -- Ethereal Portal
  DKP = hsAction:new(93672),  -- Dark Portal

}

hsSpellTable = {

  ARC = hsAction:new(556, 1),    -- Shaman: Astral Recall (Class Spell)
  DRW = hsAction:new(193753, 1), -- Druid: Dreamwalk (Class Spell)
  DHG = hsAction:new(50977, 1),  -- Death Knight: Death Gate (Class Spell)
  ZPG = hsAction:new(126892, 1), -- Monk: Zen Pilgrimage (Class Spell)

  VCM = hsAction:new(312370, 1), -- Vulpera: Camp (Racial Spell)
  VRC = hsAction:new(312372, 1), -- Vulpera: Return to camp (Racial Spell)
  DMM = hsAction:new(265225, 1), -- Dark Iron Dwarf: Mole Machine (Racial Spell)

}

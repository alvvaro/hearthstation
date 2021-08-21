--[[xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

          HEARTHSTATION
            neumotora

xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx]]

print("HEARTHSTATION: Begin load")

--------------------------------------------------------------------------------

--[[Hearthstation aims to provide a Blizzard-like UI for transportation items
and spells. It does so by displaying a series of buttons on the lower-left
part of the screen (under the chat), that contain shortcuts to the hearthstones
(regular, Garrison and Broken Isles Dalaran), whistle, teleport spells (Astral
Recall, Dreamwalk, Death Gate, Zen Pilgrimage,... -- mage portals are handled in
an embedded sub-addon), etc. In the code, these shortcuts are called actions.]]

--[[The action buttons are intended to behave the same way action bar buttons
do, that is, displaying tooltips and cooldowns. Since the intention behind
this addon is to create a UI component that mimics the rest of the WoW UI, no
configuration, settings or personalization is provided. This may or may not
change in future releases.]]

--[[Hearthstation has three main parts. The XML file that defines the button
templates, a set of functions that determines which buttons should be displayed,
and a set of functions that create and populate those buttons with actions
on the go.]]

--------------------------------------------------------------------------------

--[[Firstly, an empty stack is declared. This stack will contain every action
button that is created in order of creation. It will not contain the so-called
"hsActionButtonBig" or Main Button, which is the button for the Regular
Hearthstone that is always displayed.]]

local hsStack = {}

--[[The following function creates a new empty frame next to the previous
frame on the stack. If the stack is empty, it will create the frame next
to the Main Button.

"hsActionButton" is a virtual frame defined in the addon's XML.

When the stack length is 0, the frame is positioned relative to the
Main Button. Otherwise, it will be positioned relative to the last frame
present on the stack.

_G[*] is the environment table and it is used to access the stack from
within the function.

Please note that the function returns the frame itself; and when called,
the frame should be stored in a variable for future handling.

In LUA, frames cannot be handled directly using their XML name, but instead
should be stored in a variable. This variable name may or may not be different
from the frame name, but are internally two separate concepts. To handle a frame
given its frame name one must use the following function:

  local var = GetClickFrame(FrameName); FrameName = "string"

]]

local function hsCreateActionFrame(name)

  local var = CreateFrame("Button", name, nil, "hsActionButton")
  local point = "LEFT"
  local relativePoint = "RIGHT"
  local x, y= 10, 0

  if #hsStack ~= 0 then
    relativeTo = _G[hsStack[#hsStack]] --Actually I don't fully understand this line
  else
    relativeTo = hsActionButtonBig --The variable name, not a string
  end

  var:SetPoint(point, relativeTo, relativePoint, x, y)
  var:Hide()

  function var:Boo()  --debug

    print("Boo")  -- debug

  end --debug

  hsStack[#hsStack+1] = name

  return var

end

--[[The next functions populate the frame with an action. Populating will
define which action is to be called upon click, its icon, its tooltip and its
cooldown. These functions are defined here, for clarity sake, from more specific
to less specific.]]

--[[This function sets a GameTooltip to a frame with a specific action (spell
or item) description. Note that the GameTooltip must be cleared on each call and
specifically shown or hidden on mouse entering or leaving the frame.

While regular action bar buttons display their tooltips on the lower-right
corner of the screen, mimicking this would mean that they would be too far
away from the action buttons of the addon, so they are set to be shown on
the top right of the buttons.]]

local function hsSetTooltip(frame, action)

  if action.spell == nil then
    __, action.spell = GetItemSpell(action.ID)
  end

  --print("Post " .. action.spell)

  frame:SetScript("OnEnter", function(self)
    GameTooltip:ClearLines()
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetSpellByID(action.spell)
    GameTooltip:Show()
  end)
  frame:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
  end)

end

--[[This function sets the cooldown animation for the action frame.
It only shows the actual cooldown of the spell/object and not
the global cooldown, hence the 60s value check

The functions to retrieve cooldown information are different for
items and toys, therefore a conditional is used.]]

local function hsSetCooldown(frame, action)

  frame.cooldown:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
  frame.cooldown:SetScript("OnEvent", function(self, event, ...)
    if action.type == 0 then --item
      cdStart, cdDuration, cdEnable = GetItemCooldown(action.ID)
    elseif action.type == 1 then --spell
      cdStart, cdDuration, cdEnable = GetSpellCooldown(action.spell)
    end
    if cdDuration >= 60 then
      frame.cooldown:SetCooldown(cdStart, cdDuration, cdEnable)
    end
    hsSetTooltip(frame, action)
  end)

end

--[[This is the main drawing function for the addon. It takes an available
frame and puts an icon on it. The attribute is a macro text so different
kinds of actions (abilities, items, toys, etc.) can be called with the
same codebase.]]

function hsPopulateActionFrame(frame, action)

  frame:SetAttribute("macrotext", action.mtxt)
  frame.icon:SetTexture(action.icon)
  hsSetTooltip(frame, action)
  hsSetCooldown(frame, action)
  frame:Show()

end

--

--[[This very basic function retrieves the Hearthstone toy for the player's
covenant.]]

local function hsWhichCovenantToy()

  local hsPlayerCovenant = C_Covenants.GetActiveCovenantID()

  if hsPlayerCovenant == 1 then
    return hsCovenantTable.CKY
  elseif hsPlayerCovenant == 2 then
    return hsCovenantTable.CVT
  elseif hsPlayerCovenant == 3 then
    return hsCovenantTable.CNF
  elseif hsPlayerCovenant == 4 then
    return hsCovenantTable.CNL
  else
    return nil
  end

end

--

--[[This function is twopart. On the first part, a conditional checks
whether the player belongs to a covenant. In that case, the toy that will
be used is always the covenant Hearthstone. If the player does not
belong to one, it uses the first available Hearthstone toy, regardless
of what it is. (In my account, it shows the winter one :( )]]

local function hsWhichToy()

  if C_Covenants.GetActiveCovenantID() ~= 0 then
    return hsWhichCovenantToy()
  end

  for key, value in pairs(hsToyTable) do
    if PlayerHasToy(value.ID) then
      return value
    end
  end

end

--

--[[This function establishes the Hearthstone priority. It uses the regular
Hearthstone if its present in the bags, otherwise it uses a toy.
These two are overriden by Astral Recall if the player is a shaman, tho
it might be interesting to offer both choices (ARC and HS) since they
do not share cooldown and can be used independently]]

local function hsWhichHearthstone()

  if IsSpellKnown(hsSpellTable.ARC.ID) == true then
    return hsSpellTable.ARC
  elseif GetItemCount(hsHST.ID) == 1 then
    return hsHST
  else
    return hsWhichToy()
  end

  return hsHST -- fallback value

end

--[[This function takes the three action frames for items and hides them.
This is so they don't stay in case some object is destroyed or put in a bank]]

local function hsHideButtons()

  for count = 1, 3 do
    local frame = GetClickFrame("hsAction" .. count)
    frame:Hide()
  end

end

--[[This function loops through the item table and makes the action frame
available in case the item is found in the bags.]]

local function hsReorderButtons()

  local i = 1

  for key, value in pairs(hsItemTable) do
    if GetItemCount(value.ID) > 0 then
      hsPopulateActionFrame(GetClickFrame("hsAction" .. i), hsItemTable[key])
      i = i + 1
    end
  end

end

--[[For clarity, a single function is called upon bag updates, which
in return, calls these three functions: it hides all frames, sets a new
Hearthstone frame and sets the item frames]]

local function hsUpdateButtons()

  hsHideButtons()
  hsPopulateActionFrame(hsActionButtonBig, hsWhichHearthstone())
  hsReorderButtons()

end

--[[Called once upon addon loading, prepares 6 empty frames to be
populated later.]]

local function hsIntialize()

  for count = 1, 6 do
    hsCreateActionFrame("hsAction" .. count)
  end

end

--------------------------------------------------------------------------------

hsIntialize()

--[[The addon's main frame is listening for bag updates and updating
the frames everytime]]

local hsParentFrameVar = GetClickFrame("hsParentFrame")
hsParentFrameVar:RegisterEvent("BAG_UPDATE")
hsParentFrameVar:SetScript("OnEvent", function(self, event, ...)
  hsUpdateButtons()
end)

--------------------------------------------------------------------------------

local hsDebugFrame = hsCreateActionFrame("hsActionDebug")
local hsReload = hsHST
hsReload.mtxt = "/reload"
hsReload.icon = 135860
hsPopulateActionFrame(hsDebugFrame, hsReload)

hsDebugFrame:Boo()

--------------------------------------------------------------------------------

print("HEARTHSTATION: Loaded")

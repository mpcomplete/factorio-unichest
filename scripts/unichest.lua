local table = require('__kry_stdlib__/stdlib/utils/table')

Chest = Chest or {}

function Chest.onBuiltEntity(event, entity)
  if entity.name ~= Config.CHEST_NAME then return end
  local tagFilter = event.tags and event.tags["filter"]   -- Extract filter from a blueprint tag

  if tagFilter then
    Chest.setItemFilter(entity, tagFilter)
  elseif entity.link_id == 0 then
    Chest.setItemFilter(entity, storage.lastItemFilter or Chest.getItemFilter(entity))
  end
end

local guiData = {}
function Chest.openGui(player, entity)
  guiData[player.index] = {entity = entity, filter = Chest.getItemFilter(entity)}
  local data = guiData[player.index]
  player.gui.relative.unichestFrame.itemFilter.elem_value = data.filter
  Chest.setItemFilter(data.entity, data.filter)

  script.on_event(defines.events.on_tick, function(event)
    -- Reset any changes via the GUIs we can't control (e.g. Link bitmask and manual filtering).
    for player_index, data in pairs(guiData) do
      if not data.entity.valid then return end
      local player = game.get_player(player_index)
      player.gui.relative.unichestFrame.itemFilter.elem_value = data.filter
      Chest.setItemFilter(data.entity, data.filter)
    end
  end)

  script.on_event(defines.events.on_gui_elem_changed, function(event)
    local data = guiData[event.player_index]
    local player = game.get_player(event.player_index)
    if not data.entity.valid then return end
    local element = event.element
    if element ~= player.gui.relative.unichestFrame.itemFilter then return end
    if element.elem_value and element.elem_value ~= "" then
      -- Don't let them set an empty filter.
      data.filter = element.elem_value
    end
  end)

  script.on_event(defines.events.on_gui_closed, function(event)
    guiData[event.player_index] = nil
    if table.size(guiData) == 0 then
      script.on_event(defines.events.on_tick, nil)
      script.on_event(defines.events.on_gui_elem_changed, nil)
      script.on_event(defines.events.on_gui_closed, nil)
    end
  end)
end

function Chest.buildGui(player)
  player.gui.relative.add {
    type = "frame",
    name = "unichestFrame",
    direction = "vertical",
    caption = { "zy-unichest.heading" },
    anchor = {
      gui = defines.relative_gui_type.linked_container_gui,
      position = defines.relative_gui_position.right
    },
    visible = true
  }
  player.gui.relative.unichestFrame.add {
    type = "choose-elem-button",
    name = "itemFilter",
    tooltip = { "zy-unichest.chooseElemTooltip" },
    style = "slot_button",
    elem_type = "item-with-quality"
  }
end

function Chest.destroyGui(player)
  if player.gui.relative.unichestFrame ~= nil then player.gui.relative.unichestFrame.destroy() end
end
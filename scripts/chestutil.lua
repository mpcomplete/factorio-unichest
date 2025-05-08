local table = require('__kry_stdlib__/stdlib/utils/table')

Chest = Chest or {}

function Chest.getNextId()
  storage.nextId = (storage.nextId or 0) + 1
  return storage.nextId
end

function Chest.getOrCreateId(itemFilter, surfaceName)
  storage.filterToId = storage.filterToId or {}
  if not settings.startup["zy-unichest-per-surface"].value then surfaceName = "nauvis" end
  local key = surfaceName .. "/" .. itemFilter.name .. "/" .. itemFilter.quality
  local id = storage.filterToId[key]
  if id == nil then
    id = Chest.getNextId()
    storage.filterToId[key] = id
  end
  return id
end

function getDefaultItem()
  for k, v in pairs(prototypes.item) do
    return { name = k, quality = "normal" }
  end
  return { name = Config.CHEST_NAME, quality = "normal" }
end

function ensureValidItem(itemFilter)
  if not itemFilter or not prototypes.item[itemFilter.name] then
    return getDefaultItem()
  end
  return itemFilter
end

function Chest.getItemFilter(entity)
  local inventory = entity.get_output_inventory()
  for i = 1, #inventory do
    local filter = inventory.get_filter(i)
    if filter then
       return { name = filter.name, quality = filter.quality }
    end
  end
  game.print("Warning: Unichest has no item filter set.")
  return getDefaultItem()
end

function Chest.setItemFilter(entity, itemFilter)
  itemFilter = ensureValidItem(itemFilter)
  storage.lastItemFilter = itemFilter

  local id = Chest.getOrCreateId(itemFilter, settings.startup["zy-unichest-per-surface"].value and entity.surface.name or "nauvis")
  entity.link_id = id
  local inventory = entity.get_output_inventory()
  for i = 1, #inventory do
    inventory.set_filter(i, itemFilter)
  end
end

-- Adds fuel like coal, solid-fuel, to a thing that burns fuel.
function addBurnerCycle(cycle, entity, isOutput)
  if isOutput then return end
  if entity.burner then
    for fuelCat, _ in pairs(entity.burner.fuel_categories) do
      for _, item in pairs(prototypes.item) do
        if item.fuel_category == fuelCat then
          table.insert(cycle, { name = item.name, quality = "normal"} )
        end
      end
    end
  end
end

-- Adds ingredient/products from the entity's current recipe.
function addRecipeCycle(cycle, entity, isOutput)
  if entity.prototype.crafting_categories and entity.get_recipe() then
    local _, quality = entity.get_recipe()
    local items = isOutput and entity.get_recipe().products or entity.get_recipe().ingredients
    for _, v in pairs(items) do
      if (v.type == "item") then table.insert(cycle, {name = v.name, quality = quality.name }) end
    end
  end
end

-- Adds science packs for a lab.
function addLabCycle(cycle, entity, isOutput)
  if entity.prototype.lab_inputs then
    for _, v in pairs(entity.prototype.lab_inputs) do
      table.insert(cycle, { name = v, quality = "normal" })
    end
  end
end

-- Adds ore types for a mining drill.
function addMinerCycle(cycle, entity, isOutput)
  if entity.prototype.type == "mining-drill" and entity.mining_target and prototypes.item[entity.mining_target.name] then
    table.insert(cycle, { name = entity.mining_target.name, quality = "normal" })
  end
end

-- Adds items from the input/output inventory of a container.
function addChestInventoryCycle(cycle, entity, isOutput)
   local inventory = entity.get_inventory(defines.inventory.chest)
   if not inventory then return end
   for k,v in pairs(inventory.get_contents()) do
     table.insert(cycle, { name = v.name, quality = v.quality })
   end
end

-- Sets the chest filter based on a source entity's expected inputs/outputs.
function Chest.setItemFilterFromSource(dest, source, isOutput)
  if source == nil or dest == nil or not source.valid or not dest.valid then return end
  if dest.name ~= Config.CHEST_NAME then return end

  local itemCycle = {}
  if not isOutput then
    -- Burner fuel and labs are input-only
    addBurnerCycle(itemCycle, source, isOutput)
    addLabCycle(itemCycle, source, isOutput)
  end
  addRecipeCycle(itemCycle, source, isOutput)
  addMinerCycle(itemCycle, source, isOutput)
  addChestInventoryCycle(itemCycle, source, isOutput)

  if #itemCycle == 0 then
    -- link_id might have changed (e.g. if we pasted from a chest), so update our local metadata from it.
    Chest.setItemFilter(dest, Chest.getItemFilter(dest))
    return
  end

  if storage.lastPasteSource ~= source or storage.lastPasteAlt ~= isOutput then
    storage.lastPasteSource = source
    storage.lastPasteAlt = isOutput
    storage.lastPasteIdx = 1
  end

  local item = itemCycle[storage.lastPasteIdx or 1]
  storage.lastPasteIdx = storage.lastPasteIdx + 1
  if storage.lastPasteIdx > #itemCycle then
    storage.lastPasteIdx = 1
  end

  Chest.setItemFilter(dest, item)
end

return Chest
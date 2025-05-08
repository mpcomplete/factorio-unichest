local table = require('__kry_stdlib__/stdlib/utils/table')

Chest = Chest or {}

function Chest.getNextId()
  storage.nextId = (storage.nextId or 0) + 1
  return storage.nextId
end

function Chest.getOrCreateId(itemName)
  local id = storage.nameToId[itemName]
  if id == nil then
    id = Chest.getNextId()
    storage.nameToId[itemName] = id
  end
  return id
end

function getDefaultItem()
  for k, v in pairs(prototypes.item) do
    return k
  end
  return Config.CHEST_NAME
end

function ensureValidItem(itemName)
  if not itemName or not prototypes.item[itemName] then
    return getDefaultItem()
  end
  return itemName
end

function Chest.getNameFromId(id)
  for key, value in pairs(storage.nameToId) do
    if value == id then
      return ensureValidItem(key)
    end
  end
  return getDefaultItem()
end

function Chest.setItemFilter(entity, itemName)
  itemName = ensureValidItem(itemName)
  storage.lastItemFilter = itemName

  local id = Chest.getOrCreateId(itemName)
  entity.link_id = id
  local inventory = entity.get_output_inventory()
  for i = 1, #inventory do
    inventory.set_filter(i, itemName)
  end
end

-- Adds fuel like coal, solid-fuel, to a thing that burns fuel.
function addBurnerCycle(cycle, entity, isOutput)
  if isOutput then return end
  if entity.burner then
    for fuelCat, _ in pairs(entity.burner.fuel_categories) do
      for _, item in pairs(prototypes.item) do
        if item.fuel_category == fuelCat then
          table.insert(cycle, item.name)
        end
      end
    end
  end
end

-- Adds ingredient/products from the entity's current recipe.
function addRecipeCycle(cycle, entity, isOutput)
  if entity.prototype.crafting_categories and entity.get_recipe() then
    local items = isOutput and entity.get_recipe().products or entity.get_recipe().ingredients
    for _, v in pairs(items) do
      if (v.type == "item") then table.insert(cycle, v.name) end
    end
  end
end

-- Adds science packs for a lab.
function addLabCycle(cycle, entity, isOutput)
  if entity.prototype.lab_inputs then
    for _, v in pairs(entity.prototype.lab_inputs) do
      table.insert(cycle, v)
    end
  end
end

-- Adds ore types for a mining drill.
function addMinerCycle(cycle, entity, isOutput)
  if entity.prototype.type == "mining-drill" and entity.mining_target and prototypes.item[entity.mining_target.name] then
    table.insert(cycle, entity.mining_target.name)
  end
end

-- Adds items from the input/output inventory of a container.
function addChestInventoryCycle(cycle, entity, isOutput)
   local inventory = entity.get_inventory(defines.inventory.chest)
   if not inventory then return end
   for k,v in pairs(inventory.get_contents()) do
     table.insert(cycle, k)
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
    Chest.setItemFilter(dest, Chest.getNameFromId(dest.link_id))
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
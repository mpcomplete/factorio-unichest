local table = require('__kry_stdlib__/stdlib/utils/table')

local function create(protoName)
  --- Item ---

  local icon = "__base__/graphics/icons/linked-chest-icon.png"
  local item = table.merge(table.deepcopy(data.raw["item"]["iron-chest"]), {
    name = protoName,
    icon = icon,
    icon_size = 64,
    icon_mipmaps = 4,
    subgroup = "storage",
    order = "a[steel-chest]-a[" .. protoName .. "]",
    place_result = protoName,
    stack_size = 100,
  })

  --- Entity ---

  local inv_size = settings.startup["zy-unichest-inventory-size"].value
  local linked_chest = data.raw["linked-container"]["linked-chest"]
  local entity = table.merge(table.deepcopy(data.raw["container"]["iron-chest"]), {
    type = "linked-container",
    name = protoName,
    minable = { mining_time = 0.2, result = protoName },
    inventory_size = inv_size,
    inventory_type = "with_filters_and_bar",
    icon = linked_chest.icon,
    icon_size = linked_chest.icon_size,
    picture = linked_chest.picture,
    gui_mode = "all",
    corpse = "",
    selecttable_in_game = true,
    collision_box = { { -0.25, -0.25 }, { 0.25, 0.25 } },
    selection_box = { { -0.5, -0.5 }, { 0.5, 0.5 } }
  })

  --- Recipe ---

  local crafting_cost = settings.startup["zy-unichest-crafting-cost"].value
  local ingredients = {
      --crafting_cost == "easy" and {
        { type = "item", name = "iron-plate", amount = 20 }
  }
  ingredients =
      crafting_cost == "medium" and {
        { type = "item", name = "steel-chest",        amount = 10 },
        { type = "item", name = "iron-plate",         amount = 100 },
        { type = "item", name = "copper-plate",       amount = 100 },
        { type = "item", name = "electronic-circuit", amount = 50 },
      } or crafting_cost == "hard" and {
        { type = "item", name = "steel-chest",      amount = 20 },
        { type = "item", name = "iron-plate",       amount = 100 },
        { type = "item", name = "copper-plate",     amount = 100 },
        { type = "item", name = "advanced-circuit", amount = 50 },
        { type = "item", name = "processing-unit",  amount = 10 }
      } or ingredients
  local recipe = {
    type = "recipe",
    name = protoName,
    enabled = false,
    ingredients = ingredients,
    results = { { type = "item", name = protoName, amount = 1 } },
    allow_quality = false
  }

  --- Technology ---

  local research = settings.startup["zy-unichest-required-research"].value
  local tech = {
      -- research == "automation" and {
        count = 10,
        ingredients = {
          { "automation-science-pack", 1 },
        },
        prerequisites = {
          "logistics",
          "electronics",
          "steel-processing"
        }
      }
  tech =
      research == "logistic" and {
        count = 50,
        ingredients = {
          { "automation-science-pack", 1 },
          { "logistic-science-pack",   1 }
        },
        prerequisites = {
          "logistics",
          "fast-inserter",
          "steel-processing",
          "logistic-science-pack"
        }
      } or research == "chemical" and {
        count = 100,
        ingredients = {
          { "automation-science-pack", 1 },
          { "logistic-science-pack",   1 },
          { "chemical-science-pack",   1 }
        },
        prerequisites = {
          "logistics-2",
          "stack-inserter",
          "logistic-science-pack",
          "chemical-science-pack"
        }
      } or research == "production" and {
        count = 200,
        ingredients = {
          { "automation-science-pack", 1 },
          { "logistic-science-pack",   1 },
          { "chemical-science-pack",   1 },
          { "production-science-pack", 1 }
        },
        prerequisites = {
          "logistics-3",
          "stack-inserter",
          "advanced-electronics",
          "logistic-science-pack",
          "chemical-science-pack",
          "production-science-pack"
        }
      } or research == "utility" and {
        count = 500,
        ingredients = {
          { "automation-science-pack", 1 },
          { "logistic-science-pack",   1 },
          { "chemical-science-pack",   1 },
          { "production-science-pack", 1 },
          { "utility-science-pack",    1 }
        },
        prerequisites = {
          "logistics-3",
          "stack-inserter",
          "inserter-capacity-bonus-1",
          "logistic-science-pack",
          "chemical-science-pack",
          "production-science-pack",
          "utility-science-pack"
        }
      } or research == "space" and {
        count = 1000,
        ingredients = {
          { "automation-science-pack", 1 },
          { "logistic-science-pack",   1 },
          { "chemical-science-pack",   1 },
          { "production-science-pack", 1 },
          { "utility-science-pack",    1 },
          { "space-science-pack",      1 }
        },
        prerequisites = {
          "logistics-3",
          "stack-inserter",
          "inserter-capacity-bonus-1",
          "logistic-science-pack",
          "chemical-science-pack",
          "production-science-pack",
          "utility-science-pack",
          "space-science-pack"
        }
      } or tech
  local technology = {
    type = "technology",
    name = protoName,
    icon = icon,
    icon_size = 64,
    icon_mipmaps = 4,
    effects = {
      {
        type = "unlock-recipe",
        recipe = protoName
      }
    },
    unit = {
      count = tech.count,
      ingredients = tech.ingredients,
      time = 30
    },
    prerequisites = tech.prerequisites,
    order = "a-b-b",
  }

  return item, entity, recipe, technology
end

data:extend({ create(Config.CHEST_NAME) })
data:extend({
  {
    type = "int-setting",
    name = "zy-unichest-inventory-size",
    order = "c",
    setting_type = "startup",
    default_value = 10,
    minimum_value = 1,
    maximum_value = 4069
  },
  {
    type = "string-setting",
    name = "zy-unichest-required-research",
    setting_type = "startup",
    default_value = "chemical",
    allowed_values = { "automation", "logistic", "chemical", "production", "utility", "space" }
  },
  {
    type = "string-setting",
    name = "zy-unichest-crafting-cost",
    setting_type = "startup",
    default_value = "easy",
    allowed_values = { "easy", "medium", "hard" }
  },
  {
    type = "bool-setting",
    name = "zy-unichest-per-surface",
    setting_type = "startup",
    default_value = true
  }
})

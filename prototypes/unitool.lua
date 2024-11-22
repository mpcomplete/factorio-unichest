local icon = "__base__/graphics/icons/linked-chest-icon.png"

data:extend({
  {
    type = "selection-tool",
    name = Config.TOOL_NAME,
    icon = icon,
    flags = { "only-in-cursor", "not-stackable", "spawnable" },
    hidden = true,
    subgroup = "tool",
    order = "c[automated-construction]-b[deconstruction-planner]",
    stack_size = 1,
    icon_size = 64,
    stackable = false,
    select = {
      border_color = { r = 0, g = 1, b = 0 },
      mode = { "nothing" },
      cursor_box_type = "pair",
    },
    alt_select = {
      border_color = { r = 0, g = 1, b = 0 },
      mode = { "nothing" },
      cursor_box_type = "pair",
    },
    show_in_library = true
  },
  {
    type = "shortcut",
    name = Config.TOOL_NAME,
    order = "o[" .. Config.TOOL_NAME .. "]",
    action = "spawn-item",
    item_to_spawn = Config.TOOL_NAME,
    toggleable = true,
    icon = icon,
    small_icon = icon,
    -- icons = { {
    --   icon = icon,
    --   -- priority = "extra-high-no-scale",
    --   icon_size = 64,
    --   scale = 0.5
    -- }}
  }
})

Config = require("config")

function makeEntityPastableFrom(protoType)
  for _, entityProto in pairs(data.raw[protoType]) do
    if not entityProto.additional_pastable_entities then
      entityProto.additional_pastable_entities = {}
    end
    table.insert(entityProto.additional_pastable_entities, Config.CHEST_NAME)
  end
end

makeEntityPastableFrom("assembling-machine")
makeEntityPastableFrom("furnace")
makeEntityPastableFrom("boiler")
makeEntityPastableFrom("lab")
makeEntityPastableFrom("reactor")
makeEntityPastableFrom("mining-drill")
makeEntityPastableFrom("rocket-silo")
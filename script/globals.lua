
-- Equipment Slots

equipment = {
    "weapon",
    "helmet",
    "body",
    "hands",
    "legs",
    "feet",
    "ring",
    "acc",
}


-- Displayed Stats

stats = {
    "maxHp",
    "maxMp",
    "strength",
    "intelligence",
    "vitality",
    "armor",
    "resistance",
    "hit",
    "dodge",
    "crit",
    "critDamage",
    "luck",
}


-- Hidden Stats

extraStats = {
    "hpRegen",
    "mpRegen",
    "xpGain",
    "gpGain",
    "itemGain",
    "block",
    "parry",
    "deflect",
}


-- Elements

elements = {
    "light",
    "night",
    "fire",
    "earth",
    "air",
    "water",
}


-- Add elemental resistance and damage to extraStats

for k, v in ipairs(elements) do
    table.insert(extraStats, k.."Damage")
    table.insert(extraStats, k.."Resistance")
end
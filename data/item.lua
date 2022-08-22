return {
    ["Material"] = {
        description = {"You use this to craft. What a surprise."},
        rarity = "common",
    },
    ["Health Potion"] = {
        description = {"Crazy that the sussy red liquid makes you healthier."},
        rarity = "uncommon",
        consumable = true,
        effect = {hp = {2, 9}},
        target = "entity",
    },
    ["Throwing Knife"] = {
        description = {"Don't cut yourself :)."},
        rarity = "uncommon",
        consumable = true,
        effect = {hp = {-4,-5}},
        target = "entity",
    },
    ["Sword"] = {
        description = {"Wow, it's a sword! I've never seen one of these before!"},
        rarity = "common",
        equipment = true,
        slot = "weapon",
        effect = {hp = {-10, -10}},
    },
    ["Dual Knives"] = {
        description = {"You know what's better than one knife? Two!"},
        rarity = "rare",
        equipment = true,
        slot = "weapon",
        effect = {{hp = {-1, -3}}, {hp = {-1, -3}}},
    },
    ["Chestplate"] = {
        description = {"It has boobs drawn on it in Sharpie. Classic."},
        rarity = "common",
        equipment = true,
        slot = "body",
        stats = {armor = 100, maxHp = 1},
    },
    ["Wheat Biscuit"] = {
        description = {"Stale and harder than rock, it's a favorite alternative", "currency for the locals."},
        rarity = "common",
        consumable = true,
        effect = {hp = {2, 3}},
        target = "entity",  
    },
    ["Jar of Water"] = {
        description = {"You're not even sure this is safe to drink."},
        rarity = "common",
        consumable = true,
        effect = {mp = {3, 5}},
        target = "entiy",
    },
    ["Tin Helmet"] = {
        description = {"They can't hear your thoughts with this on."},
        rarity = "common",
        equipment = true,
        slot = "head",
        stats = {armor = 1, maxHp = 1},
    },
    ["Tin Chestplate"] = {
        description = {"Does this even help?"},
        rarity = "common",
        equipment = true,
        slot = "body",
        stats = {armor = 2},
    },
    ["Tin Guantlets"] = {
        descripion = {"They're almost not even worth wearing for the protection due", "to the high level of discomfort."},
        rarity = "common",
        equipment = true,
        slot = "hands",
        stats = {armor = 1},
    },
    ["Tin Leggings"] = {
        description = {"If you're a dude, these really chafe in uncomfortable places."},
        rarity = "common",
        equipment = true,
        slot = "legs",
        stats = {armor = 2},
    },
    ["Tin Boots"] = {
        description = {"Boy, your feet are gonna be sore."},
        rarity = "common",
        equipment = true,
        slot = "feet",
        stats = {armor = 1},
    },
    ["Tin Knife"] = {
        description = {"A knife is defined as 'an instrument used for cutting'.", "This barely makes the cut."},
        rarity = "common",
        equipment = true,
        slot = "weapon",
        effect = {hp = {-1, -2}},
    },
    ["Tin Sword"] = {
        description = {"Not gonna make another crappy pun. It's just a bad sword."},
        rarity = "common",
        equipment = true,
        slot = "weapon",
        effect = {hp = {-1, -3}, crit = 4},
    },
    ["Thatch Headband"] = {
        description = {"I mean, at least it blocks the sun?"},
        rarity = "common",
        equipment = true,
        slot = "head",
        stats = {maxMp = 2},
    },
    ["Thatch Robes"] = {
        description = {"Makes you look like a hay bale."},
        rarity = "common",
        equipment = true,
        slot = "body",
        stats = {armor = 1, maxMp = 2},
    },
    ["Thatch Gloves"] = {
        description = {"They really tickle."},
        rarity = "common",
        equipment = true,
        slot = "body",
        stats = {maxMp = 2},
    },
    ["Thatch Pants"] = {
        description = {"Honestly, not even that bad for a pair of pants."},
        rarity = "common",
        equipment = true,
        slot = "legs",
        stats = {armor = 1, maxMp = 2},
    },
    ["Thatch Loafers"] = {
        description = {"Do I even need to tell you how uncomfortable these are?"},
        rarity = "common",
        equipment = true,
        slot = "feet",
        stats = {maxMp = 2},
    },
    ["Pine Staff"] = {
        description = {"Kids would be very happy to have a stick as long and straight as this."},
        rarity = "common",
        equipment = true,
        slot = "weapon",
        effect = {hp = {-1, -3}},
        stats = {intelligence = 1, maxMp = 2},
    },
    ["Pine Wand"] = {
        description = {"It's just a twig. Really?"},
        rarity = "common",
        equipment = true,
        slot = "weapon",
        effect = {hp = {-1, -2}},
        stats = {intelligence = 2, maxMp = 1},
    },
    ["Goat Leather Helmet"] = {
        description = {"It kinda smells."},
        rarity = "common",
        equipment = true,
        slot = "head",
        stats = {armor = 1},
    },
    ["Goat Leather Vest"] = {
        description = {"It's still got the hair on the outside."},
        rarity = "common",
        equipment = true,
        slot = "body",
        stats = {armor = 2},
    },
    ["Goat Leather Gloves"] = {
        descripion = {"Your hands, when you pull them out, are sweaty and smell foul."},
        rarity = "common",
        equipment = true,
        slot = "hands",
        stats = {armor = 1},
    },
    ["Goat Leather Pants"] = {
        description = {"External pubic hair."},
        rarity = "common",
        equipment = true,
        slot = "legs",
        stats = {armor = 2},
    },
    ["Goat Leather Shoes"] = {
        description = {"Surprisingly comfortable!"},
        rarity = "common",
        equipment = true,
        slot = "feet",
        stats = {armor = 1},
    },
    ["Gunpowder"] = {
        description = {"Highly volatile."},
        rarity = "uncommon",
    },
    ["Rosy Tincture"] = {
        description = {"Pagan power! Its effects are mostly just placebo."},
        rarity = "uncommon",
        consumable = true,
        effect = {hp = {4, 6}},
        target = "entity",
    },
    ["Daisy Oil"] = {
        description = {"At least it smells okay. Get ready for sneezes, though."},
        rarity = "uncommon",
        consumable = true,
        effect = {mp = {5, 9}},
        target = "entity",
    },
    ["Filthy Bandage"] = {
        description = {"It may not heal well, but it might stop the bleeding."},
        rarity = "common",
        consumbale = true,
        effect = {hp = {1, 3}},
        target = "entity",
    },
}
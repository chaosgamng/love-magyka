return {
    ["Brown Slime"] = {
        level = 1,
        attackEffect = {hp={-1, -2}},
        baseStats = {
            maxHp = 4,
            maxMp = 2,
            hit = 84,
            dodge = 2,
            crit = 2,
        },
        drops = {
            xp = {1, 4},
            gp = {2, 6},
            drops = {
                {"Sword", {1, 3}, 100},
                {"Material", 5, 50},
            },
        },
    },
    ["Green Slime"] = {
        level = 2,
        attackEffect = {hp={-1, -3}},
        baseStats = {
            maxHp = 6,
            maxMp = 2,
            armor = 1,
            hit = 85,
            dodge = 2,
            crit = 3,
        },
        drops = {
            xp = {2, 5},
            gp = {3, 7},
            drops = {
                {"Sword", {1, 3}, 100},
                {"Material", 5, 50},
            },
        },
    },
    ["Gray Slime"] = {
        xp = {2, 5},
        gp = {3, 7},
        level = 3,
        attackEffect = {hp={-2, -4}},
        baseStats = {
            maxHp = 12,
            maxMp = 4,
            armor = 3,
            hit = 86,
            dodge = 2,
            crit = 3,
        },
    },
    ["Blue Slime"] = {
        xp = {3, 7},
        gp = {4, 9},
        level = 4,
        attackEffect = {hp={-3, -5}},
        baseStats = {
            maxHp = 17,
            maxMp = 6,
            armor = 4,
            hit = 87,
            dodge = 3,
            crit = 4,
        },
    },
    ["Purple Slime"] = {
        xp = {4, 9},
        gp = {5, 11},
        level = 5,
        attackEffect = {hp={-4, -7}},
        baseStats = {
            maxHp = 22,
            maxMp = 8,
            armor = 5,
            hit = 88,
            dodge = 3,
            crit = 4,
        },
    },
    ["Orange Slime"] = {
        xp = {5, 10},
        gp = {6, 13},
        level = 6,
        attackEffect = {hp={-5, -8}},
        baseStats = {
            maxHp = 28,
            maxMp = 11,
            armor = 7,
            hit = 88,
            dodge = 3,
            crit = 4,
        },
    },
    ["Enemy"] = {
        xp = {1, 1},
        gp = {1, 1},
        attackEffect = {hp={-5, -5}},
    }
}
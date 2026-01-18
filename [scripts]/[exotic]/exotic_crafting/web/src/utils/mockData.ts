import type { InventoryItems, Recipes, UserProfile } from "../types";

export const userProfileMock: UserProfile = {
    level: 12,
    fullname: "John Doe",
    xp: 1200,
    levelProgress: "50.0%"
};

export const mockRecipes: Recipes = [
    {
        label: "Healing Potion",
        shortDescription: "Restores a small amount of health",
        fullDescription: "A basic potion that restores vitality.",
        itemName: "healing_potion",
        craftItems: {
            herb: { label: "Herb", quantity: 2 },
            water: { label: "Water", quantity: 2 }
        },
        craftDuration: 5000,
        requiredLevel: 4
    },
];

export const userInventoryMock: InventoryItems = {
    herb: 12,
    water: 8,
    crystal_dust: 5,
    iron_ingot: 10,
    wood: 15,
    oil: 7,
    cloth: 9,
    flint: 4,
    string: 6,
    shadow_essence: 2,
    golden_feather: 1,
    dragon_scale: 3
};
export interface CraftItem {
    label: string;
    quantity: number;
}

export interface Recipe {
    label: string;
    shortDescription: string;
    fullDescription: string;
    itemName: string;
    craftItems: {
        [key: string]: CraftItem;
    };
    craftDuration: number;
    requiredLevel: number;
}

export type Recipes = Recipe[];

export interface UserProfile {
    level: number;
    fullname: string;
    xp: number;
    levelProgress: string;
}

export interface InventoryItems {
    [key: string]: number;
}
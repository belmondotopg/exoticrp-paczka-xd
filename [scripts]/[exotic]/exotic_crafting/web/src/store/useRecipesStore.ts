import { create } from "zustand";
import type { Recipe } from "../types";
import { mockRecipes } from "../utils/mockData";

interface RecipesState {
    recipes: Recipe[];
    selectedRecipe: Recipe | null;
    setRecipes: (recipes: Recipe[]) => void;
    selectRecipe: (recipe: Recipe | null) => void;
}

export const useRecipesStore = create<RecipesState>((set) => ({
    recipes: mockRecipes,
    selectedRecipe: null,
    setRecipes: (recipes) => set({ recipes }),
    selectRecipe: (recipe) => set({ selectedRecipe: recipe }),
}));

import { create } from "zustand";
import type { UserProfile, InventoryItems } from "../types";
import { userInventoryMock, userProfileMock } from "../utils/mockData";

interface UserState {
    profile: UserProfile;
    inventory: InventoryItems;
    mugshot: string | null;
    setProfile: (profile: UserProfile) => void;
    setInventory: (inventory: InventoryItems) => void;
    setMugshot: (mugshot: string) => void;
    updateInventoryItem: (item: string, amount: number) => void;
    addItem: (item: string, amount: number) => void;
}

export const useUserStore = create<UserState>((set) => ({
    profile: userProfileMock,
    inventory: userInventoryMock,
    mugshot: null,
    
    setProfile: (profile) => set({ profile }),
    setInventory: (inventory) => set({ inventory }),
    setMugshot: (mugshot) => set({ mugshot }),
    updateInventoryItem: (item, amount) => {
        set((state) => ({
            inventory: {
                ...state.inventory,
                [item]: amount
            }
        }))
    },
    addItem: (item: string, amount: number) => {
        set((state) => ({
            inventory: {
                ...state.inventory,
                [item]: (state.inventory[item] || 0) + amount
            }
        }))
    }
}));
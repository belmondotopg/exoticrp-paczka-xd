import { create } from "zustand";

import type { Setting, SettingValue } from "../types/settings";
import { SETTINGS } from "../constants";

function getSettingFromLocalStorageByKeys (keys: string[]) {
    const obj: { [key: string]: string } = {};

    keys.forEach((key) => {
        const value = localStorage.getItem(key);
        if (value) {
            obj[key] = value;
        }
    });

    return obj;
}

function getSettingsKeys (settings: Setting[]) {
    return settings.map((setting) => setting.name);
}

export function fetchSettings (settings: Setting[]) {
    const keys = getSettingsKeys(settings);
    const obj = getSettingFromLocalStorageByKeys(keys);
    
    const settingsValues: { [key: string]: SettingValue } = {};

    settings.forEach((setting) => {
        const plainValue = obj[setting.name];
        
        try {
            if (!plainValue) throw new Error();
            const { success, data } = setting.schema.safeParse(plainValue);

            if (!success) throw new Error();

            settingsValues[setting.name] = data as SettingValue;
        } catch {
            settingsValues[setting.name] = setting.defaultValue;
        }
    });

    return settingsValues;
}

export function loadSettings (
    settings: Setting[],
    settingsValues: { [key: string]: SettingValue }
) {
    settings.forEach((setting) => {
        if (setting.onValueChange) {
            setting.onValueChange(settingsValues[setting.name]);
        }
    })

    if (process.env.NODE_ENV === "production") {
        fetch(`https://${GetParentResourceName()}/settings`, { method: "POST", body: JSON.stringify(settingsValues) });
    }

    return settingsValues;
}

export function getDefaultSettings (settings: Setting[]) {
    return settings.reduce((acc, setting) => {
        acc[setting.name] = setting.defaultValue;
        return acc;
    }, {} as { [key: string]: SettingValue });
}

interface SettingsStore {
    settings: { [key: string]: SettingValue };
    setSettingValue: (key: string, value: SettingValue) => void;
    resetSettings: () => void;
}

export const useSettings = create<SettingsStore>((set) => ({
    settings: loadSettings(SETTINGS, fetchSettings(SETTINGS)),
    setSettingValue: (key, value) => {
        set((state) => {
            const newSettings = { ...state.settings, [key]: value };

            const setting = SETTINGS.find((s) => s.name === key);
            if (setting && setting.onValueChange) {
                setting.onValueChange(value);
            }

            localStorage.setItem(key, value.toString());

            if (process.env.NODE_ENV === "production") {
                fetch(`https://${GetParentResourceName()}/setting-value-changed`, { method: "POST", body: JSON.stringify({ key, value }) });
            }

            return { settings: newSettings };
        });
    },
    resetSettings: () => {
        set({ settings: getDefaultSettings(SETTINGS) });

        for (const setting of SETTINGS) {
            localStorage.removeItem(setting.name);
            if (setting.onValueChange) {
                setting.onValueChange(setting.defaultValue);
            }
        }
    }
}))
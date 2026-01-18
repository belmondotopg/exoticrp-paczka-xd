import { atom, useAtom, useAtomValue, useSetAtom } from "jotai";

import { userSettings } from "../types/settings";

const settingsData = atom<userSettings | null>(null)

export const useSettingsState = () => useAtomValue(settingsData)
export const useSettingsData = () => useAtom(settingsData)
export const useSetSettings = () => useSetAtom(settingsData)
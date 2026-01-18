import { atom, useAtom, useAtomValue, useSetAtom } from "jotai";

import playerData from "../types/playerData";

const playerDataAtom = atom<playerData | null>(null)

export const usePlayerDataState = () => useAtomValue(playerDataAtom)
export const usePlayerData = () => useAtom(playerDataAtom)
export const useSetPlayerData = () => useSetAtom(playerDataAtom)
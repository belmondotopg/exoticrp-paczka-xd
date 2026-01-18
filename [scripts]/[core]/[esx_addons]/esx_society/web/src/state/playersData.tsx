import { atom, useAtom, useAtomValue, useSetAtom } from "jotai";

import playersData from "../types/playersData";

const playersDataAtom = atom<playersData[]>([])

export const usePlayersDataState = () => useAtomValue(playersDataAtom)
export const usePlayersData = () => useAtom(playersDataAtom)
export const useSetPlayersData = () => useSetAtom(playersDataAtom)
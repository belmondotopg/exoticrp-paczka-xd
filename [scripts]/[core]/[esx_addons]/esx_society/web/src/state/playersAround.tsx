import { atom, useAtom, useAtomValue, useSetAtom } from "jotai";

import playersAround from "../types/playersAround";

const playersAroundAtom = atom<playersAround[]>([])

export const usePlayerAroundState = () => useAtomValue(playersAroundAtom)
export const usePlayerAround = () => useAtom(playersAroundAtom)
export const useSetPlayerAround = () => useSetAtom(playersAroundAtom)
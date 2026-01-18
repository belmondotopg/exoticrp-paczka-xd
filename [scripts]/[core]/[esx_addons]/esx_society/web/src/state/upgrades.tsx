import { atom, useAtomValue, useSetAtom } from "jotai";
import { UpgradesData } from "../types/upgrades";

const upgardes_meta = atom<UpgradesData[]>([])

export const useUpgradesData = () => useAtomValue(upgardes_meta)
export const useSetUpgradesData = () => useSetAtom(upgardes_meta)
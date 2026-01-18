import { atom, useAtomValue, useSetAtom } from "jotai";
import { UpgradesLegalData } from "../types/upgradeslegal";

const upgardes_meta = atom<UpgradesLegalData[]>([])

export const useUpgradesLegalData = () => useAtomValue(upgardes_meta)
export const useSetUpgradesLegalData = () => useSetAtom(upgardes_meta)
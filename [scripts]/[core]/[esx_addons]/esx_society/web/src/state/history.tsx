import { atom, useAtom, useAtomValue, useSetAtom } from "jotai";

import kariee_history from "../types/history";

const historyAtomData = atom<kariee_history[]>([])

export const useHistoryDataState = () => useAtomValue(historyAtomData)
export const useHistoryData = () => useAtom(historyAtomData)
export const useSetHistoryData = () => useSetAtom(historyAtomData)
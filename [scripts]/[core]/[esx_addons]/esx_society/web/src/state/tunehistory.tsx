import { atom, useAtom, useAtomValue, useSetAtom } from "jotai";

import tune_history from "../types/tunehistory";

const historyAtomData = atom<tune_history[]>([])

export const useTuneHistoryDataState = () => useAtomValue(historyAtomData)
export const useTuneHistoryData = () => useAtom(historyAtomData)
export const useSetTuneHistoryData = () => useSetAtom(historyAtomData)
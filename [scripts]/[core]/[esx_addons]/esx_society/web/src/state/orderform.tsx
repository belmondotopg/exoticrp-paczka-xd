import { atom, useAtom, useAtomValue, useSetAtom } from "jotai";

import order_form from "../types/orderform";

const historyAtomData = atom<order_form[]>([])

export const useOrderFormDataState = () => useAtomValue(historyAtomData)
export const useOrderFormData = () => useAtom(historyAtomData)
export const useSetOrderFormData = () => useSetAtom(historyAtomData)
import { atom, useAtom, useAtomValue, useSetAtom } from "jotai";

const hrefData = atom<string>('')

export const useHrefState = () => useAtomValue(hrefData)
export const useHrefData = () => useAtom(hrefData)
export const useSetHref = () => useSetAtom(hrefData)
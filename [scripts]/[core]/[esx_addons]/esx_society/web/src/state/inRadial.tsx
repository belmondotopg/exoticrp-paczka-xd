import { atom, useAtomValue, useSetAtom } from "jotai";

const atomRadial = atom<boolean>(false)

export const useInRadialData = () => useAtomValue(atomRadial)
export const useSetInRadialData = () => useSetAtom(atomRadial)
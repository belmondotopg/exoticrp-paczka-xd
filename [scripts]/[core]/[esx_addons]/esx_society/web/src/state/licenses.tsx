import { atom, useAtom, useAtomValue, useSetAtom } from "jotai";

const atomLicenses = atom<string[]>([])

export const useJobLicensesData = () => useAtomValue(atomLicenses)
export const useSetJobLicensesData = () => useSetAtom(atomLicenses)
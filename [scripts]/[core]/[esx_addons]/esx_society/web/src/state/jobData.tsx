import { atom, useAtom, useAtomValue, useSetAtom } from "jotai";

import kariee_job_data from "../types/jobData";

const jobAtomData = atom<kariee_job_data | null>(null)

export const useJobDataState = () => useAtomValue(jobAtomData)
export const useJobData = () => useAtom(jobAtomData)
export const useSetJobData = () => useSetAtom(jobAtomData)
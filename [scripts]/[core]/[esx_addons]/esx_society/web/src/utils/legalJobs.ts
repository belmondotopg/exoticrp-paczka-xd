// Lista legal jobs z config.lua
export const LEGAL_JOBS = [
    'uwucafe',
    'whitewidow',
    'bahama_mamas',
    'beanmachine',
    'lumberjack',
    'pizza',
    'pearl',
    'mexicana',
    'taxi',
    'weazelnews',
]

export const isLegalJob = (jobName: string | undefined | null): boolean => {
    if (!jobName) return false
    return LEGAL_JOBS.includes(jobName)
}

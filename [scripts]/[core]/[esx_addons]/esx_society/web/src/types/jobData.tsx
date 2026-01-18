export interface kariee_job_data {
    jobName: string;
    jobLabel: string;
    jobImage: string;
    jobMoney: string;
    jobPlayers: number;
    jobData: {
        jobDataOnline: number;
        jobDataLevel: number;
        jobDataLevelPoints: number;
        jobDataNextLevelPoints: number;
        jobDataStrefy: number;
        jobDataKursy: number;
        jobDataFaktury: number;
        jobDataMandaty: number;
        jobDataWyroki: number;
        jobDataBonusZarobki: number;
        jobDataBonusDropy: number;
    };
}

export default kariee_job_data
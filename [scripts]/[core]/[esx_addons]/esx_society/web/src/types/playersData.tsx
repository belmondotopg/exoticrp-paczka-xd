interface pLices {
    [key: string]: boolean;
}

export interface playersData {
    playerIdentifier: string;
    playerActive: boolean;
    playerJob: string;
    playerJobGrade: number;
    playerJobGradeLabel: string;
    playerName: string;
    playerFirstName: string;
    playerLastName: string;
    playerID: number;
    playerPermID: number;
    playerDiscordID: string;
    playerHours: number;
    playerTunes: number;
    playerTunesMoney: number;
    playerKursy: number;
    playerBadge: string;
    playerPaycheck: number;
    playerLicenses: pLices;
}[]

export default playersData
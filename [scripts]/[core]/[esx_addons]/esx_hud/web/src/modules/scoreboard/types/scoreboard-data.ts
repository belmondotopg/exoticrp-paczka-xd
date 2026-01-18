export type DangerCode = "green" | "orange" | "red" | "black";

export type ScoreboardData = {
    onlinePlayers: number;
    playerName: string;
    playerJob: string;
    playerJobGrade: string;
    lspd: number;
    lssd: number;
    ems: number;
    doj: number;
    lsc: number;
    ec: number;
    dangerCode: DangerCode;
}
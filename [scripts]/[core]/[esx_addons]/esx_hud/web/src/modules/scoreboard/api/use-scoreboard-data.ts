import { useNuiData } from "@yankes/fivem-react/hooks";
import { type ScoreboardData } from "@/modules/scoreboard/types/scoreboard-data";

const MOCK_DATA: ScoreboardData = {
    onlinePlayers: 263,
    playerName: "Carlos Monge",
    playerJob: "Bezrobotny",
    playerJobGrade: "Brak",
    lspd: 8,
    lssd: 10,
    ems: 12,
    doj: 3,
    lsc: 8,
    ec: 11,
    dangerCode: "green"
}

export const useScoreboardData = () => {
    return useNuiData<ScoreboardData | null>("scoreboard-data", process.env.NODE_ENV === "development" ? MOCK_DATA : null);
}
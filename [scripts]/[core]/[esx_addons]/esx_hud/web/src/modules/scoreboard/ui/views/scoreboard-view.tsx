import { useMemo } from "react";
import { UsersIcon } from "lucide-react";
import { useVisible } from "@yankes/fivem-react/hooks";

import { cn } from "@/lib/utils";
import { Box } from "@/components/box";
import { Badge } from "@/components/ui/badge";
import { Separator } from "@/components/ui/separator";
import { useScoreboardData } from "@/modules/scoreboard/api/use-scoreboard-data";
import { ScoreboardStat } from "@/modules/scoreboard/ui/components/scoreboard-stat";
import type { DangerCode } from "@/modules/scoreboard/types/scoreboard-data";

const dangerCodeLabels: Record<DangerCode, string> = {
    green: "Zielony",
    orange: "Pomarańczowy",
    red: "Czerwony",
    black: "Czarny"
} as const;

const dangerCodeColors: Record<DangerCode, string> = {
    green: "144 100% 39%",
    orange: "25 100% 50%",
    red: "357 96% 58%",
    black: "0 0% 0%"
} as const;

export const ScoreboardView = () => {
    const { visible } = useVisible("scoreboard", false);
    const data = useScoreboardData();

    const dangerCodeStyle = useMemo(() => {
        if (!data) return {};
        return {
            backgroundColor: `hsla(${dangerCodeColors[data.dangerCode]} / 0.35)`
        };
    }, [data?.dangerCode]);

    return data && (
        <Box
            className={cn(
                "w-[300px] px-5 py-4 flex flex-col gap-y-4 rounded-xl fixed top-1/2 -translate-y-1/2 right-10 transition-opacity duration-300",
                !visible && "opacity-0 scale-0 pointer-events-none"
            )}
        >
            <div className="flex items-center justify-between gap-x-3.5">
                <div className="flex items-center gap-x-2">
                    <img
                        src="logo.webp"
                        alt=""
                        className="w-[55px]"
                    />
                    <div className="flex flex-col gap-y-0.5 items-start">
                        <span className="font-bold text-sm text-primary">Exotic RolePlay</span>
                        <span className="font-medium text-[10px] text-muted-foreground">discord.gg/exoticrp</span>
                    </div>
                </div>
                <Badge>
                    <UsersIcon />
                    {data.onlinePlayers}
                </Badge>
            </div>
            <Separator />
            <div className="flex flex-col gap-y-1 items-start">
                <span className="font-bold text-xs">{data.playerName}</span>
                <span className="font-semibold text-[11px] text-muted-foreground">{data.playerJob} - {data.playerJobGrade}</span>
            </div>
            <Separator />
            <div className="grid grid-cols-3 gap-3">
                <ScoreboardStat
                    title="LSPD"
                    value={data.lspd}
                    color="#0088FC"
                />
                <ScoreboardStat
                    title="LSSD"
                    value={data.lssd}
                    color="#BE923D"
                />
                <ScoreboardStat
                    title="EMS"
                    value={data.ems}
                    color="#EC3139"
                />
                <ScoreboardStat
                    title="DOJ"
                    value={data.doj}
                    color="#F3D044"
                />
                <ScoreboardStat
                    title="LSC"
                    value={data.lsc}
                    color="#8F8F8F"
                />
                <ScoreboardStat
                    title="EC"
                    value={data.ec}
                    color="#FF8C0C"
                />
            </div>
            <Separator />
            <div className="flex items-center justify-between gap-x-3.5">
                <span className="font-semibold text-xs">Kod Zagrożenia</span>
                <Badge style={dangerCodeStyle}>
                    {dangerCodeLabels[data.dangerCode]}
                </Badge>
            </div>
        </Box>
    )
}

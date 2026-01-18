import { useVisible } from "@yankes/fivem-react/hooks";

import { cn } from "@/lib/utils";
import { Box } from "@/components/box";
import { usePoliceRadarData } from "@/modules/police-radar/api/use-police-radar";
import { PoliceRadarStat } from "@/modules/police-radar/ui/components/police-radar-stat";

export const PoliceRadarView = () => {
    const { visible } = useVisible("police-radar", false);
    const data = usePoliceRadarData();

    return data && (
        <Box
            className={cn(
                "flex items-center gap-x-6 px-4.5 py-3 rounded-[10px] fixed left-1/2 bottom-28 -translate-x-1/2 transition-opacity duration-300",
                !visible && "opacity-0 scale-0 pointer-events-none"
            )}
        >
            <PoliceRadarStat
                label="Rejestracja"
                value={data.plate}
            />
            <div className="w-[1px] h-8 bg-[hsla(0_0%_100%_/_0.15)]" />
            <PoliceRadarStat
                label="Model"
                value={data.model}
            />
            <div className="w-[1px] h-8 bg-[hsla(0_0%_100%_/_0.15)]" />
            <PoliceRadarStat
                label="Prędkość"
                value={`${data.speed} KM/H`}
            />
            <div className="w-[1px] h-8 bg-[hsla(0_0%_100%_/_0.15)]" />
            <PoliceRadarStat
                label="Właściciel"
                value={data.owner}
            />
        </Box>
    )
}
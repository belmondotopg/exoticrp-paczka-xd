import { useMemo } from "react";
import { useVisible } from "@yankes/fivem-react/hooks"
import { FuelIcon } from "lucide-react";

import { cn } from "@/lib/utils";
import { useSettings } from "@/modules/settings/hooks/use-settings";

import { useCarhudData } from "../../api/use-carhud-data";
import { GearBox } from "../components/gear-box";
import { EngineIcon } from "../components/engine-icon";
import { SeatbeltsIcon } from "../components/seatbelts-icon";
import { CarhudCircle } from "../components/carhud-circle";
import { MAX_RPM } from "../../constants";
import DirectionDisplay from "../components/direction-display";

export const CarhudView = () => {
    const { visible } = useVisible("carhud", false);
    const data = useCarhudData();
    const { settings } = useSettings();

    const speedDisplay = useMemo(() => {
        if (!data) return null;
        const zerosCount = Math.max(0, 3 - data.kmh.toString().length);
        return (
            <>
                {Array.from({ length: zerosCount }, (_, index) => (
                    <span key={index} className="text-[hsla(0_0%_100%_/_0.5)]">0</span>
                ))}
                {data.kmh}
            </>
        );
    }, [data?.kmh]);

    const fuelBarStyle = useMemo(() => ({
        height: `${Math.min(data?.fuel ?? 0, 100)}%`,
        boxShadow: "inset 0 -2px 4px hsla(0 0% 0% / 0.15)"
    }), [data?.fuel]);

    const rpmBarStyle = useMemo(() => ({
        width: `${Math.min((data?.rpm ?? 0) / MAX_RPM, 1) * 100}%`,
        boxShadow: "inset 0 -2px 4px hsla(0 0% 0% / 0.15)"
    }), [data?.rpm]);

    const displayRpm = useMemo(() => {
        if (!data) return 0;
        return Math.round(data.rpm / 100) * 100;
    }, [data?.rpm]);

    return data && settings["carhud-appearance"] !== "hide" && (
        <>
            <DirectionDisplay
                visible={visible}
                direction={data.direction}
                roadName={data.roadName}
                rotation={data.rotation}
            />
            <div
                className={cn(
                    "fixed bottom-8 right-10 flex flex-col transition-opacity duration-300 items-end justify-end w-[200px]",
                    settings["carhud-appearance"] === "analog" && "bottom-20 right-20",
                    !visible && "opacity-0 scale-0 pointer-events-none"
                )}
            >
                <div className="flex items-end gap-x-3">
                    <div className="flex gap-x-2.5 items-end w-[52px]">
                        <EngineIcon className="size-6" color={data.isEngineOn ? "#00C950" : "#FB2C36"} />
                        <SeatbeltsIcon className="size-5" color={data.isSeatbeltOn ? "#00C950" : "#FB2C36"} />
                    </div>

                    <div className="flex flex-col items-center w-[90px]">
                        <span className="font-extrabold text-[38px] tabular-nums text-center w-full">
                            {speedDisplay}
                        </span>

                        <span className="font-bold text-sm uppercase -mt-1.5 text-center w-full">
                            km/h
                        </span>
                    </div>

                    <div className="w-7 h-[70px] rounded-[6px] bg-[hsla(0_0%_15%_/_0.75)] border border-neutral-700 shadow flex items-end justify-center relative overflow-hidden">
                        <FuelIcon className="size-3 relative z-10 mb-1.5" />
                        <div className="absolute bottom-0 left-0 w-full rounded-[4px] bg-primary transition duration-300" style={fuelBarStyle} />
                    </div>
                </div>

                {settings["carhud-appearance"] === "digital" && (
                    <div className="w-full mt-5 px-3 py-1 rounded-[8px] bg-[hsla(0_0%_15%_/_0.75)] border border-neutral-700 shadow relative overflow-hidden">
                        <span className="font-bold text-xs uppercase relative z-10 tabular-nums">{displayRpm} RPM</span>
                        <div className="top-0 left-0 h-full rounded-[6px] bg-primary absolute transition duration-300" style={rpmBarStyle} />
                    </div>
                )}

                <div className="mt-2 w-full grid grid-cols-7 gap-[3px]">
                    <GearBox gear="R" isActive={data.gear === "R"} />
                    <GearBox gear={1} isActive={data.gear === 1} />
                    <GearBox gear={2} isActive={data.gear === 2} />
                    <GearBox gear={3} isActive={data.gear === 3} />
                    <GearBox gear={4} isActive={data.gear === 4} />
                    <GearBox gear={5} isActive={data.gear === 5} />
                    <GearBox gear={6} isActive={data.gear === 6} />
                </div>

                {settings["carhud-appearance"] === "analog" && (
                    <CarhudCircle
                        rpm={data.rpm}
                        width={276}
                        height={276}
                        className="absolute top-1/2 left-1/2 size-[350px] -translate-1/2 -rotate-[130deg]"
                    />
                )}
            </div>
        </>
    )
}

import { useEffect, useState, useMemo } from "react";
import { BatteryMediumIcon } from "lucide-react";
import { useVisible } from "@yankes/fivem-react/hooks";

import { cn } from "@/lib/utils";
import { useBodycamData } from "@/modules/bodycam/api/use-bodycam-data";
import { useSettings } from "@/modules/settings/hooks/use-settings";

const MONTHS = ["Styczeń", "Luty", "Marzec", "Kwiecień", "Maj", "Czerwiec", "Lipiec", "Sierpień", "Wrzesień", "Październik", "Listopad", "Grudzień"] as const;

function formatDate (date: Date): string {
    if (!date || isNaN(date.getTime())) {
        date = new Date();
    }
    return `${date.getDate()} ${MONTHS[date.getMonth()]} ${date.getFullYear()}, ${date.getHours()}:${date.getMinutes().toString().padStart(2, "0")}:${date.getSeconds().toString().padStart(2, "0")}`
}

export const BodycamView = () => {
    const { visible } = useVisible("bodycam", false);
    const data = useBodycamData();
    const { settings } = useSettings();

    const [currentDate, setCurrentDate] = useState(new Date());
    
    const isVisible = useMemo(() => {
        return visible && settings["show-bodycam"] && !!data;
    }, [visible, settings, data]);

    useEffect(() => {
        if (!isVisible) return;
        
        const interval = setInterval(() => setCurrentDate(new Date()), 1000);
        return () => clearInterval(interval);
    }, [isVisible]);

    return data && (
        <div
            className={cn(
                "bg-[hsla(0_0%_9%_/_0.6)] rounded-lg p-3 w-[230px] flex flex-col gap-y-1.5 transition-opacity duration-300 font-mono fixed top-10 right-85 shadow",
                !isVisible && "opacity-0 scale-0 pointer-events-none"
            )}
        >
            <div className="flex items-center justify-between gap-x-3.5">
                <span className="font-semibold text-xs uppercase">
                    {data.gopro ? "GOPRO" : "AXON BODY 3 REC"}
                </span>
                <div className="flex items-center gap-x-2">
                    <BatteryMediumIcon className="size-4" />
                    <div className="size-1.5 bg-red-400 rounded-full animate-pulse" />
                </div>
            </div>
            <div className="flex justify-between items-end gap-x-3.5 leading-4">
                <span className="text-[9px]">
                    {data.fullName}<br />
                    {data.job} [{data.jobGrade}] - {data.badge}<br />
                    {formatDate(currentDate)}
                </span>
                {!data.gopro && (
                    <img
                        src="bodycam.webp"
                        alt=""
                        className="size-14 object-cover object-center opacity-50"
                    />
                )}
            </div>
        </div>
    )
}

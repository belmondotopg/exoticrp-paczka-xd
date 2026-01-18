import { useMemo } from "react";
import { useVisible } from "@yankes/fivem-react/hooks";
import { FingerprintIcon, UserIcon } from "lucide-react";

import { cn } from "@/lib/utils";
import { WatermarkStat } from "@/modules/watermark/ui/components/watermark-stat";
import { useWatermarkData } from "@/modules/watermark/api/use-watermark-data";
import { UserMicrophone } from "@/modules/watermark/ui/components/user-microphone";
import { useMicrophone } from "@/api/use-microphone";
import { useSettings } from "@/modules/settings/hooks/use-settings";

export const WatermarkView = () => {
    const { visible } = useVisible("watermark", true);
    const { settings } = useSettings();

    const data = useWatermarkData();
    const microphone = useMicrophone();

    const uuidDisplay = useMemo(() => {
        if (!data) return null;
        
        const uuidStr = data.uuid.toString();
        const paddedZerosCount = 4 - uuidStr.length;
        
        return (
            <>
                {Array.from({ length: paddedZerosCount }, (_, index) => (
                    <span key={index} className="text-muted-foreground">0</span>
                ))}
                {uuidStr}
            </>
        );
    }, [data?.uuid]);

    return data && (
        <div
            className={cn(
                "fixed top-10 right-10 flex items-center gap-x-4.5 transition-opacity duration-300",
                (!visible || !settings["show-watermark"]) && "opacity-0 scale-0 pointer-events-none"
            )}
        >
            <div className="flex flex-col gap-y-1">
                <WatermarkStat icon={UserIcon}>
                    {data.serverId}
                </WatermarkStat>
                <WatermarkStat icon={FingerprintIcon}>
                    {uuidDisplay}
                </WatermarkStat>
            </div>
            <img
                src="logo.webp"
                alt=""
                className="h-[75px]"
            />
            <UserMicrophone
                distance={microphone?.voiceDistance ?? 2}
                isTalking={!!microphone?.isTalking}
            />
        </div>
    )
}

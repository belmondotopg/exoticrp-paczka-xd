import { memo } from "react";
import { MicIcon } from "lucide-react";

import { cn } from "@/lib/utils";
import type { VoiceDistance } from "@/api/use-microphone";

interface Props {
    distance: VoiceDistance;
    isTalking: boolean;
}

export const UserMicrophone = memo(({
    distance,
    isTalking
}: Props) => {
    return (
        <div className={cn("flex items-center gap-x-1 transition duration-300", !isTalking && "opacity-50")}>
            <MicIcon
                className="text-white size-8"
            />
            <div className="flex items-center gap-x-[2px]">
                <div
                    className={cn("w-[3px] scale-x-75 h-[13px] bg-white shadow rounded-full transform duration-300 opacity-0", distance >= 1 && "opacity-100")}
                />
                <div
                    className={cn("w-[3px] scale-x-75 h-[20px] bg-white shadow rounded-full transform duration-300 opacity-25", distance >= 2 && "opacity-100")}
                />
                <div
                    className={cn("w-[3px] scale-x-75 h-[25px] bg-white shadow rounded-full transform duration-300 opacity-25", distance >= 3 && "opacity-100")}
                />
            </div>
        </div>
    )
}, (prevProps, nextProps) => {
    return prevProps.distance === nextProps.distance && 
           prevProps.isTalking === nextProps.isTalking;
});

UserMicrophone.displayName = 'UserMicrophone';

import { memo } from "react";
import { Badge } from "@/components/ui/badge";
import type { RadioMember as RadioMemberType } from "@/modules/radio/types/radio-data";

export const RadioMember = memo(({
    name,
    tag,
    isTalking,
    isDead,
    channelNumber
}: RadioMemberType & { channelNumber?: number }) => { 
    const isFactionChannel = channelNumber !== undefined && channelNumber >= 1 && channelNumber <= 10;
    
    return (
        <div className="w-full flex items-center justify-between gap-x-2.5">
            <div className="flex items-center gap-x-1.5">
                {tag && isFactionChannel && (
                    <Badge size="sm" className="w-[50px] truncate">
                        {tag}
                    </Badge>
                )}
                <span className="font-medium text-[10px]">{name}</span>
            </div>
            <div className="flex items-center gap-x-1">
                {isTalking && <div className="size-1.5 rounded-full bg-primary animate-pulse" />}
                {isDead && <div className="size-1.5 rounded-full bg-red-400" />}
            </div>
        </div>
    )
}, (prevProps, nextProps) => {
    return prevProps.name === nextProps.name && 
           prevProps.isTalking === nextProps.isTalking &&
           prevProps.isDead === nextProps.isDead &&
           prevProps.tag === nextProps.tag;
});

RadioMember.displayName = 'RadioMember';

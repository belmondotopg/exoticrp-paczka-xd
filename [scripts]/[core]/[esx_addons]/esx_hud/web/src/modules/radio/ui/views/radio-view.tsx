import { useVisible } from "@yankes/fivem-react/hooks"
import { RadioIcon, UsersIcon } from "lucide-react";

import { cn } from "@/lib/utils";
import { useRadioData } from "@/modules/radio/api/use-radio-data";
import { Box } from "@/components/box";
import { Badge } from "@/components/ui/badge";
import { Separator } from "@/components/ui/separator";
import { RadioMember } from "@/modules/radio/ui/components/radio-member";

export const RadioView = () => {
    const { visible } = useVisible("radio", false);
    const data = useRadioData();

    return data && (
        <Box
            className={cn(
                "w-[230px] px-4 py-3 flex flex-col gap-y-3 fixed left-10 top-1/2 -translate-y-1/2 transition-opacity duration-300",
                !visible && "opacity-0 scale-0 pointer-events-none"
            )}
            style={{
                backgroundImage: "none"
            }}
        >
            <div className="flex items-center justify-between gap-x-3.5">
                <div className="flex items-center gap-x-1.5">
                    <RadioIcon className="size-5 text-primary" />
                    <span className="text-xs font-bold">
                        Kanał&nbsp;<span className="text-primary">#{data.channel}</span>
                    </span>
                </div>
                <Badge className="text-[11px]">
                    <UsersIcon className="!size-3" />
                    {data.members.length.toLocaleString("pl-PL", { maximumFractionDigits: 0 })}
                </Badge>
            </div>
            <Separator />
            <div className="flex flex-col gap-y-2.5">
                {data.members.slice(0, (data.maxMembers || 8)).map((member, index) => (
                    <RadioMember key={member.tag || `${member.name}-${index}`} {...member} channelNumber={data.channelNumber} />
                ))}
            </div>
        </Box>
    )
}
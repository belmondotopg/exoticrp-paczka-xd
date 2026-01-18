import { memo } from "react";
import type { LucideIcon } from "lucide-react";
import { Box } from "@/components/box";

interface Props {
    icon: LucideIcon;
    children: React.ReactNode;
}

export const WatermarkStat = memo(({
    icon: Icon,
    children
}: Props) => {
    return (
        <Box
            className="flex items-center gap-x-1 px-3 py-1.5 rounded-[10px] border-1 w-full"
        >
            <Icon
                className="text-primary size-3.5 shrink-0"
            />   
            <span className="flex-1 font-medium text-xs text-center">{children}</span>
        </Box>
    )
}, (prevProps, nextProps) => {
    return prevProps.children === nextProps.children;
});

WatermarkStat.displayName = 'WatermarkStat';

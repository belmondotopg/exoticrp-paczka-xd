import { memo } from "react";
import type { LucideIcon } from "lucide-react";
import { Box } from "@/components/box";
import type { IconType } from "react-icons/lib";

interface Props {
    icon: LucideIcon | IconType;
    value: number;
    color: string;
}

export const HudBox = memo(({
    icon: Icon,
    value,
    color
}: Props) => {
    return (
        <Box
            className="bg-neutral-900 size-11 rounded-md flex items-center justify-center p-0 relative border-0"
            style={{
                backgroundImage: `linear-gradient(to top, hsla(${color} / 0.25) ${value}%, transparent ${value}%)`
            }}
        >
            <Icon
                color={`hsl(${color})`}
                size={22}
                className="relative z-10"
            />
            <div
                className="rounded-[10px] absolute top-1/2 left-1/2 -translate-1/2 size-[calc(100%_+_4px)] -z-[1]"
                style={{
                    backgroundImage: `linear-gradient(to top, hsl(${color}) ${value}%, #545454 ${value}%)`
                }}
            />
        </Box>
    )
}, (prevProps, nextProps) => {
    // Custom comparison - tylko rerenderuj gdy zmienią się kluczowe wartości
    return prevProps.value === nextProps.value && 
           prevProps.color === nextProps.color;
});

HudBox.displayName = 'HudBox';

import { memo } from "react";
import { cn } from "@/lib/utils";
import type { GearType } from "../../types/carhud-data";

interface Props {
    gear: GearType;
    isActive?: boolean;
}

export const GearBox = memo(({ gear, isActive }: Props) => {
    return (
        <div
            className={cn(
                "w-full aspect-square rounded-[6px] bg-[hsla(0_0%_15%_/_0.8)] border border-neutral-700 shadow-sm font-bold uppercase text-[10px] transition-colors duration-300 grid place-items-center",
                isActive && "bg-[hsla(0_0%_25%_/_0.8)]"
            )}
        >
            {gear}
        </div>
    )
}, (prevProps, nextProps) => {
    return prevProps.isActive === nextProps.isActive;
});

GearBox.displayName = 'GearBox';

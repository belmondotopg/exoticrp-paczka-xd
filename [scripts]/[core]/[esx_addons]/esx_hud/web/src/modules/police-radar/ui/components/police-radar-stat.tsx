import { memo } from "react";

interface Props {
    label: string;
    value: string;
}

export const PoliceRadarStat = memo(({ label, value }: Props) => {
    return (
        <div className="flex flex-col gap-y-1 w-20">
            <span className="text-[10px] text-muted-foreground font-semibold truncate">{label}</span>
            <span className="text-xs text-primary font-bold truncate">{value}</span>
        </div>
    )   
}, (prevProps, nextProps) => {
    return prevProps.value === nextProps.value;
});

PoliceRadarStat.displayName = 'PoliceRadarStat';

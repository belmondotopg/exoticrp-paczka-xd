import { memo, useMemo } from "react";

interface Props {
    title: string;
    value: number;
    color: string;
}

export const ScoreboardStat = memo(({ title, value, color }: Props) => {
    if (typeof value !== "number") {
        throw new Error(`${value} undefined on ${title}`)
    }

    const colorStyle = useMemo(() => ({ color }), [color]);

    return (
        <div className="flex flex-col justify-center items-center gap-y-1">
            <span className="font-semibold text-[10px] text-center">{title}</span>
            <span className="font-bold text-sm text-center" style={colorStyle}>
                {value}
            </span>
        </div>
    )
}, (prevProps, nextProps) => {
    return prevProps.value === nextProps.value;
});

ScoreboardStat.displayName = 'ScoreboardStat';

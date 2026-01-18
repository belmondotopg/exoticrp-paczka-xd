import { memo, useMemo } from "react";
import { useSettings } from "@/modules/settings/hooks/use-settings";
import { parseHSL } from "@/modules/settings/lib/utils";
import { MAX_RPM } from "../../constants";

const getLighterColor = (hsl: string) => {
    const {h,s,l} = parseHSL(hsl);
    return `hsl(${h} ${s}% ${Math.min(100, l + 25)}%)`;
}

interface Props {
    rpm: number;
    width: number;
    height: number;
    className?: string;
}

export const CarhudCircle = memo(({ rpm, width, height, className }: Props) => {
    const { settings } = useSettings();

    const colors = useMemo(() => {
        const primaryColor = settings["primary-color"] as string;
        return {
            primary: primaryColor,
            lighter: getLighterColor(primaryColor)
        };
    }, [settings["primary-color"]]);

    const rpmPercent = useMemo(() => {
        const percent = Math.min(rpm / MAX_RPM, 1) * 55;
        return Math.round(percent / 2) * 2;
    }, [rpm]);

    const gradientStyle = useMemo(() => ({
        width: "100%",
        height: "100%",
        transition: ".3s linear",
        background: `conic-gradient(var(--primary) 0%, ${colors.lighter} ${rpmPercent}%, hsla(0 0 25% / 0.5) ${rpmPercent}%, hsla(0 0 25% / 0.5) 55%, transparent 55%)`
    }), [colors.lighter, rpmPercent]);

    return (
        <svg
            width={width}
            height={height}
            viewBox={`0 0 ${width} ${height}`}
            xmlns="http://www.w3.org/2000/svg"
            className={className}
        >
            <defs>
                <mask id="stroke-mask">
                    <rect width="100%" height="100%" fill="black" />
                    <circle
                        cx="138"
                        cy="138"
                        r="120"
                        stroke="white"
                        strokeWidth="12"
                        fill="none"
                    />
                </mask>
            </defs>

            <foreignObject x="0" y="0" width="276" height="276" mask="url(#stroke-mask)">
                <g xmlns="http://www.w3.org/1999/xhtml">
                    <div style={gradientStyle} />
                </g>
            </foreignObject>
        </svg>
    );
}, (prevProps, nextProps) => {
    return Math.abs(prevProps.rpm - nextProps.rpm) < 50;
});

CarhudCircle.displayName = 'CarhudCircle';

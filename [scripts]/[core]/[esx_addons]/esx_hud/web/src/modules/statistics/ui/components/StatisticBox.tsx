import { useMemo, useEffect } from "react";
import type { Statistic } from "../../types/Statistics";
import { motion, useMotionValue, useTransform, animate } from "framer-motion";

const COLORS = {
    default: { light: "#FFD16E", dark: "#9E3D00" },
    green: { light: "#8FD14F", dark: "#3D7C0F" },
    blue: { light: "#6E85FF", dark: "#003D7C" },
    red: { light: "#FF6E6E", dark: "#7C0000" },
};

const StatisticBox = ({
    label,
    level,
    current,
    required,
    unit = "",
    colorKey,
}: Statistic) => {
    const color = COLORS[colorKey as keyof typeof COLORS] ?? COLORS.default;

    const gradientId = useMemo(
        () => `progressGradient-${label}-${colorKey ?? "default"}`,
        [label, colorKey]
    );

    const progressMotion = useMotionValue(0);
    const valueMotion = useMotionValue(0);
    const circleProgress = useMotionValue(0);

    const radius = 42;
    const circumference = 2 * Math.PI * radius;
    const arcLength = circumference * 0.75;

    const hasData = required > 0;
    const progress = hasData ? Math.min(100, (current / required) * 100) : 0;

    const progressPercentage = useTransform(
        progressMotion,
        (v) => `${Math.round(v)}%`
    );

    const valueDisplay = useTransform(
        valueMotion,
        (v) => `${Math.round(v)} ${unit}`
    );

    const strokeDashoffset = useTransform(
        circleProgress,
        [0, 100],
        [arcLength, arcLength - (progress / 100) * arcLength]
    );

    useEffect(() => {
        if (!hasData) return;

        const progressAnim = animate(progressMotion, progress, {
            duration: 1,
            ease: "linear",
        });

        const valueAnim = animate(valueMotion, required - current, {
            duration: 1,
            ease: "linear",
        });

        const circleAnim = animate(circleProgress, 100, {
            duration: 1,
            ease: "linear",
        });

        return () => {
            progressAnim.stop();
            valueAnim.stop();
            circleAnim.stop();
        };
    }, [current, required]);

    return (
        <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.4 }}
            className="flex gap-4 items-center"
        >
            <div className="relative w-[5vw] h-[5vw]">
                <svg viewBox="0 0 100 100" className="rotate-[135deg]">
                    <defs>
                        <linearGradient id={gradientId} x1="0%" y1="0%" x2="100%" y2="0%">
                            <stop offset="0%" stopColor={color.light} />
                            <stop offset="100%" stopColor={color.dark} />
                        </linearGradient>
                    </defs>

                    <circle
                        cx="50"
                        cy="50"
                        r={radius}
                        stroke="rgba(0,0,0,0.35)"
                        strokeWidth="7.5"
                        fill="none"
                        strokeDasharray={`${arcLength} ${circumference}`}
                        strokeLinecap="round"
                    />

                    <motion.circle
                        cx="50"
                        cy="50"
                        r={radius}
                        stroke={`url(#${gradientId})`}
                        strokeWidth="7.5"
                        fill="none"
                        strokeDasharray={`${arcLength} ${circumference}`}
                        strokeDashoffset={strokeDashoffset}
                        strokeLinecap="round"
                    />
                </svg>

                <div className="absolute inset-0 flex items-center justify-center">
                    <p className="text-white text-[2vw] font-extrabold">{level}</p>
                    <motion.p className="absolute -bottom-[0.4vh] text-[#B2B2B2] text-[0.65vw] font-bold">
                        {progressPercentage}
                    </motion.p>
                </div>
            </div>

            <div className="flex flex-col gap-[0.7vh]">
                <span className="leading-[1.9vh]">
                    <p className="text-[#848484] font-[500] text-[0.65vw]">Statystyka</p>
                    <p className="text-[#e8e8e8] text-[0.85vw] font-[700]">{label}</p>
                </span>
                <span className="leading-[1.9vh]">
                    <p className="text-[#848484] font-[500] text-[0.65vw]">
                        Do następnego poziomu
                    </p>
                    {hasData ? (
                        <motion.p
                            className="text-[0.85vw] font-bold"
                            style={{ color: color.light }}
                        >
                            {valueDisplay}
                        </motion.p>
                    ) : (
                        <p className="text-[#848484] text-[0.85vw] font-bold">
                            BRAK DANYCH
                        </p>
                    )}
                </span>
            </div>
        </motion.div>
    );
};

export default StatisticBox;
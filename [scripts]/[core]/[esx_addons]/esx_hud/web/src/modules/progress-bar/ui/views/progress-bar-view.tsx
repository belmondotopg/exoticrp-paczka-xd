import { useEffect, useState, useMemo } from "react";
import { LoaderIcon } from "lucide-react";

import { Box } from "@/components/box"
import { useProgressBar } from "@/modules/progress-bar/api/use-progress-bar";
import { DEFAULT_PROGRESS_BAR_DURATION } from "@/modules/progress-bar/constants";

export const ProgressBarView = () => {
    const { data } = useProgressBar();

    const [remainedTime, setRemainedTime] = useState(0);

    const duration = useMemo(() => {
        return data?.duration ?? DEFAULT_PROGRESS_BAR_DURATION;
    }, [data?.duration]);

    useEffect(() => {
        if (!data) return;

        setRemainedTime(duration);

        const interval = setInterval(() => {
            setRemainedTime(prev => Math.max(0, prev - 1));
        }, 1000);

        return () => clearInterval(interval);
    }, [data, duration]);

    const animationStyle = useMemo(() => ({
        animation: `width-to-full linear ${duration}s`
    }), [duration]);

    const backgroundStyle = useMemo(() => ({
        backgroundColor: "hsla(var(--primary-hsl) / 0.2)",
        animation: `width-to-full linear ${duration}s`
    }), [duration]);

    return data && (
        <div
            id="progress-bar"
            className="w-[338px] fixed left-1/2 -translate-x-1/2 bottom-28 p-0.5 rounded-[16px] overflow-hidden"
            style={{
                animation: "in 200ms ease-out"
            }}
        >
            <Box
                className="w-full relative px-5 py-4 flex items-center justify-between gap-x-2.5 rounded-xl bg-neutral-900 border-none overflow-hidden"
                style={{
                    backgroundImage: "none"
                }}
            >
                <div className="w-[40px] relative z-10">
                    <LoaderIcon className="text-primary size-4 animate-spin animation-duration-[2000ms]" />
                </div>
                <span className="text-sm font-medium relative z-10">
                    {data.text}
                </span>
                <span className="w-[40px] text-end text-sm font-medium text-neutral-500 relative z-10">
                    {remainedTime}s
                </span>
                <div
                    className="size-full absolute top-0 left-0 z-0 w-full"
                    style={backgroundStyle}
                />
            </Box>
            <div
                className="size-full absolute top-1/2 left-0 -translate-y-1/2 bg-neutral-600 -z-[1] w-full"
            />
            <div
                className="size-full absolute top-1/2 left-0 -translate-y-1/2 bg-primary -z-[1] w-full"
                style={animationStyle}
            />
        </div>
    )
}

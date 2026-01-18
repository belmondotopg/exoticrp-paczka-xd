import { useEffect, useState } from "react";
import { useNuiMessage } from "@yankes/fivem-react/hooks";

import type { ProgressBarData } from "@/modules/progress-bar/types/progress-bar-data";
import { DEFAULT_PROGRESS_BAR_DURATION } from "@/modules/progress-bar/constants";

// const MOCK_DATA: ProgressBarData = {
//     text: "Trwa tworzenie broni",
//     duration: 30
// }

export const useProgressBar = () => {
    const [data, setData] = useState<ProgressBarData | null>(null);

    const createProgressBar = (values: ProgressBarData) => {
        const data = {
            duration: values.duration ?? DEFAULT_PROGRESS_BAR_DURATION,
            ...values,
        };

        setData(data);
    }

    const cancelProgressBar = () => {
        const bar = document.getElementById("progress-bar");
        if (bar) {
            bar.style.animation = "out 200ms ease-out";
        }

        setTimeout(() => {
            setData(null);
        }, 200);
    }

    useEffect(() => {
        // Don't run effect if data is null (component initialization)
        if (!data) return;

        const duration = data.duration ?? DEFAULT_PROGRESS_BAR_DURATION;

        const timeoutAnimation = setTimeout(() => {
            const bar = document.getElementById("progress-bar");
            if (bar) {
                bar.style.animation = "out 200ms ease-out";
                // bar.style.opacity = "0";
            }
        }, duration * 1000);

        const timeout = setTimeout(() => {
            // if (process.env.NODE_ENV === "development") return;
            setData(null);

            if (process.env.NODE_ENV === "production") {
                fetch(`https://${GetParentResourceName()}/progress-bar/close`, { method: "POST" })
                    .catch(() => {});
            }
        }, duration * 1000 + 200);

        return () => {
            clearTimeout(timeout);
            clearTimeout(timeoutAnimation);
        }
    }, [data]);

    useNuiMessage<{ eventName: string, progressBar: ProgressBarData }>("progress-bar:create", (data) => data?.progressBar && createProgressBar(data?.progressBar));
    useNuiMessage<{ eventName: string }>("progress-bar:cancel", () => cancelProgressBar());

    // useEffect(() => {
    //     if (process.env.NODE_ENV === "development") setData(MOCK_DATA);
    // }, []);

    return { data, createProgressBar, cancelProgressBar };
}
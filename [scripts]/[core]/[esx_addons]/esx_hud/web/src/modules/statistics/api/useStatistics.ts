import { useEffect, useState } from "react";
import { fetchNui } from "@yankes/fivem-react/utils";

import type { Statistic } from "../types/Statistics";
import { useNuiMessage } from "@yankes/fivem-react/hooks";

export const useStatistics = () => {
    const [visible, setVisible] = useState<boolean>(false);
    const [statistics, setStatistics] = useState<Statistic[]>([]);

    useNuiMessage<{ eventName: string, statistics: Statistic[] }>("openStatisticsMenu", (data) => {
        if (data?.statistics) setStatistics(data.statistics);
        setVisible(true);
    })

    const closeStatisticsMenu = () => {
        setVisible(false);
        fetchNui("closeStatisticsMenu").catch(() => {});
    }
    
    useEffect(() => {
        const handleEscapeKey = (event: KeyboardEvent) => {
            if (!visible) {
                return;
            }
            
            if (event.key === "Escape") {
                closeStatisticsMenu();
            }
        }

        window.addEventListener("keydown", handleEscapeKey)
        return () => window.removeEventListener("keydown", handleEscapeKey)
    }, [visible])

    return {
        visible,
        statistics,
        closeStatisticsMenu,
    }
}
import { useEffect, useState } from "react";
import type { PoliceRadarData } from "@/modules/police-radar/types/police-radar-data";

const MOCK_DATA: PoliceRadarData = {
    plate: "ABC 123",
    model: "BMW M5",
    speed: 100,
    owner: "John Doe"
}


export const usePoliceRadarData = () => {
    const [isFreezed, setIsFreezed] = useState(false);
    const [data, setData] = useState<PoliceRadarData | null>(process.env.NODE_ENV === "development" ? MOCK_DATA : null);

    useEffect(() => {
        interface MessageData {
            eventName: "nui:data:update";
            dataId: "police-radar";
            data: PoliceRadarData | null;
        }

        const onMessage = (e: MessageEvent<MessageData>) => {
            if (e.data.eventName !== "nui:data:update" || e.data.dataId !== "police-radar") return;
            if (isFreezed) return;

            setData(e.data.data);
        }

        window.addEventListener("message", onMessage);

        return () => window.removeEventListener("message", onMessage);
    }, [isFreezed]);

    useEffect(() => {
        interface MessageData {
            eventName: "nui:police-radar:freeze";
            freeze: boolean;
        }

        const onMessage = ({ data: eventData }: MessageEvent<MessageData>) => {
            if (eventData.eventName !== "nui:police-radar:freeze") return;
            setIsFreezed(eventData.freeze);
        }

        window.addEventListener("message", onMessage);

        return () => window.removeEventListener("message", onMessage);
    }, []);

    return data;
}
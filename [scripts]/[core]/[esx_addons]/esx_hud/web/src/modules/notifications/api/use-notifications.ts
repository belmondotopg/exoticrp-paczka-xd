import { useState } from "react";
import { useNuiMessage } from "@yankes/fivem-react/hooks";
import uniqid from "uniqid";

import type { Notification } from "@/modules/notifications/types/notification";
import { DEFAULT_NOTIFICATION_DURATION, NOTIFICATION_OUT_ANIMATION_DURATION } from "../constnats";

// const MOCK_DATA: Notification[] = [
//     {
//         html: `Serwer zostanie zresetowny za <span class="text-c font-medium">10 minut</span>`,
//     },
//     {
//         html: `Serwer zostanie zresetowny za <span class="text-c font-medium">10 minut</span>`,
//         hideHeader: true
//     },
//     {
//         type: "success",
//         html: "Pomyślnie odebrano paczkę z dostawą."
//     },
//     {
//         type: "error",
//         html: "Nie możesz teraz wykonać tej czynności"
//     }
// ];

export const useNotifications = () => {
    const [notifications, setNotifications] = useState<Notification[]>([]);

    const pushNotification = (notification: Notification) => {
        const id = notification.id ?? uniqid();
        const duration = notification.duration ?? DEFAULT_NOTIFICATION_DURATION;

        setNotifications((prev) => [{ id, duration, ...notification }, ...prev]);

        setTimeout(() => {
            setNotifications((prev) => prev.filter((n) => n.id !== id));
        }, duration + NOTIFICATION_OUT_ANIMATION_DURATION);
    }

    useNuiMessage<{ eventName: string; data: Notification }>("notification:push", (data) => { 
        if (data?.data) {
            pushNotification(data.data);
        }
    });

    return { notifications, pushNotification };
}
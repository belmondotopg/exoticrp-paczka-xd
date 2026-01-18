import { useState } from "react";
import { useNuiMessage } from "@yankes/fivem-react/hooks";

import type { ChatMessage } from "@/modules/chat/types/chat-message";

const mockData: ChatMessage[] = [
    {
        title: "xEcllent",
        icon: "lucide-message-circle",
        tags: ["47", "LOOC"],
        text: "Nie słychać cię",
        timestamp: Date.now() / 1000,
        themeColor: "218 12% 64%"
    },
    {
        title: "Ogłoszenie",
        icon: "lucide-megaphone",
        html: "Za <span class='text-c'>5 minut</span> odbędzie się restart serwera",
        timestamp: Date.now() / 1000,
        themeColor: "47 100% 50%"
    },
    {
        title: "John Doe",
        icon: "lucide-message-circle",
        tags: ["84", "DO"],
        text: "Czy pada deszcz?",
        timestamp: Date.now() / 1000,
        themeColor: "273 100% 64%"
    },
]

const MAX_MESSAGES = 100;

export const useChatMessages = () => {
    const [messages, setMessages] = useState<ChatMessage[]>(process.env.NODE_ENV === "production" ? [] : mockData);

    useNuiMessage<{ eventName: string; messages?: ChatMessage[]; message?: ChatMessage; }>("chat:messages", (data) => {
        if (!data) return;

        if (data.eventName === "chat:messages:set" && data.messages) {
            // Walidacja i limit przy ustawianiu całej listy
            const validMessages = data.messages
                .filter(msg => msg && typeof msg.timestamp === 'number' && !isNaN(msg.timestamp))
                .map(msg => ({
                    ...msg,
                    timestamp: msg.timestamp || Date.now() / 1000
                }));
            setMessages(validMessages.slice(-MAX_MESSAGES));
        }

        if (data.eventName === "chat:messages:insert" && data.message) {
            setMessages((prev) => {
                if (!data.message) return prev;
                // Walidacja timestamp
                if (typeof data.message.timestamp !== 'number' || isNaN(data.message.timestamp)) {
                    data.message.timestamp = Date.now() / 1000;
                }
                const newMessages = [...prev, data.message];
                // Limit wiadomości do ostatnich 100 - zapobiega wyciekom pamięci
                return newMessages.slice(-MAX_MESSAGES);
            })
        }
    });

    return messages;
}

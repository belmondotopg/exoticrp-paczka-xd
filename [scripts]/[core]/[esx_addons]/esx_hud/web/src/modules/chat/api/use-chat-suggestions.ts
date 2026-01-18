import { useNuiData } from "@yankes/fivem-react/hooks";

import type { ChatSuggestion } from "@/modules/chat/types/chat-suggestion";

const mockData: ChatSuggestion[] = [
    {
        command: "me",
        args: ["opis"],
        description: "Wysyła opis narracyjny"
    },
    {
        command: "dm",
        args: ["id_gracza", "wiadomość"],
        description: "Wyślij wiadomość prywatną do gracza"
    }
];

export const useChatSuggestions = () => {
    return useNuiData("chat-suggestions", process.env.NODE_ENV === "production" ? [] : mockData) ?? [];
}
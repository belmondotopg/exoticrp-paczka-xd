import { useEffect, useRef} from "react";

import type { ChatMessage } from "@/modules/chat/types/chat-message";
import { ChatMessageCard } from "@/modules/chat/ui/components/chat-message-card";
import { useSettings } from "@/modules/settings/hooks/use-settings";

interface Props {
    messages: ChatMessage[];
    visible: boolean;
}

export const MessagesList = ({ messages, visible}: Props) => {
    const ref = useRef<HTMLDivElement>(null);
    const { settings } = useSettings();

    useEffect(() => {
        if (visible) {
            if (ref.current) ref.current.style.opacity = "1";
            return;
        } else {
            if (settings["show-chat"]) {
                if (ref.current) ref.current.style.opacity = "1";
            } else {
                if (ref.current) ref.current.style.opacity = "0";
                return;
            }
        }

        const timeout = setTimeout(() => {
            if (ref.current) ref.current.style.opacity = "0";
        }, 5000);
        
        return () => clearTimeout(timeout);
    }, [messages, visible, settings]);

    return (
        <div ref={ref} className="flex flex-col gap-y-2.5 h-[275px] overflow-y-auto no-scroll transition-opacity duration-300">
            {messages.map((message, index) => (
                <ChatMessageCard 
                    key={`${message.timestamp}-${index}`}
                    {...message} 
                />
            ))}
        </div>
    )
}

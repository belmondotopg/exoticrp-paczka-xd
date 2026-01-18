import { useEffect, useState } from "react";
import { useVisible } from "@yankes/fivem-react/hooks"
import { fetchNui } from "@yankes/fivem-react/utils";

import { useChatMessages } from "@/modules/chat/api/use-chat-messages";
import { useChatSuggestions } from "@/modules/chat/api/use-chat-suggestions";
import { MessagesList } from "@/modules/chat/ui/components/messages-list";
import { ChatInput } from "@/modules/chat/ui/components/chat-input";
import { SuggestionsList } from "@/modules/chat/ui/components/suggestions-list";

const MAX_HISTORY = 100;

export const ChatView = () => {
    const { visible } = useVisible("chat", false);
    const messages = useChatMessages();
    const suggestions = useChatSuggestions();

    const [currentValue, setCurrentValue] = useState("");
    const [history, setHistory] = useState<string[]>([]);
    const [historyIndex, setHistoryIndex] = useState<number | null>(null);

    const onSubmit = (value: string) => {
        fetchNui("/chat:submit", value);
        if (value !== "") {
            setHistory((prev) => {
                const newHistory = [...prev, value];
                return newHistory.slice(-MAX_HISTORY);
            });
        }
        setHistoryIndex(null);
    }

    useEffect(() => {
        if (visible) {
            setCurrentValue("");
            setHistoryIndex(null);
        }
    }, [visible]);

    return (
        <div className="flex flex-col gap-y-3 fixed top-10 left-10 w-[400px]">
            <MessagesList messages={messages} visible={visible} />
            {visible && (
                <>
                    <ChatInput
                        value={currentValue}
                        onValueChange={setCurrentValue}
                        forceFocus={visible}
                        onSubmit={onSubmit}
                        history={history}
                        historyIndex={historyIndex}
                        setHistoryIndex={setHistoryIndex}
                    />
                    <SuggestionsList
                        suggestions={suggestions}
                        currentValue={currentValue}
                        onSuggestionClick={(suggestion) =>
                            setCurrentValue(`/${suggestion.command.toLowerCase()} ${suggestion.args.map(arg => `[${arg.toLowerCase()}]`).join(" ")}`)
                        }
                    />
                </>
            )}
        </div>
    )
}

import { useMemo } from "react";

import { Box } from "@/components/box";
import type { ChatSuggestion as ChatSuggestionType } from "@/modules/chat/types/chat-suggestion";
import { ChatSuggestion } from "@/modules/chat/ui/components/chat-suggestion";

interface Props {
    suggestions: ChatSuggestionType[];
    currentValue: string;
    onSuggestionClick: (suggestion: ChatSuggestionType) => void;
}

export const SuggestionsList = ({ suggestions, currentValue, onSuggestionClick }: Props) => {
    const filteredSuggestions = useMemo(() => {
        return suggestions.filter((suggestion) => {
            const inputCommand = currentValue.split(" ")[0].slice(1).toLowerCase();
            return suggestion.command.toLowerCase().startsWith(inputCommand);
        });
    }, [suggestions, currentValue]);

    const activeArg = useMemo(() => {
        return currentValue.split(" ").length - 2;
    }, [currentValue]);

    return currentValue.startsWith("/") && filteredSuggestions.length > 0 && (
        <Box className="p-4 rounded-[10px] flex flex-col gap-y-3 items-start max-h-40 overflow-y-auto">
            {filteredSuggestions.map((suggestion) => (
                <ChatSuggestion 
                    key={suggestion.command} 
                    suggestion={suggestion} 
                    activeArg={activeArg} 
                    onClick={() => onSuggestionClick(suggestion)} 
                />
            ))}
        </Box>
    )
}
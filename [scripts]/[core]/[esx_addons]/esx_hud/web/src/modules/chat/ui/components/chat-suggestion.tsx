import { Badge } from "@/components/ui/badge";
import type { ChatSuggestion as ChatSuggestionType } from "@/modules/chat/types/chat-suggestion";

interface Props {
    suggestion: ChatSuggestionType;
    activeArg: number;
    onClick: () => void;
}

export const ChatSuggestion = ({ suggestion, activeArg, onClick }: Props) => {
    return (
        <button className="flex flex-col gap-y-1.5 transition hover:opacity-80 cursor-pointer" onClick={onClick}>
            <div className="flex items-center gap-x-1.5">
                <span className="text-sm font-semibold lowercase">/{suggestion.command}</span>
                {suggestion.args.map((arg, argIndex) => (
                    <Badge 
                        size="sm" 
                        key={`${suggestion.command}-arg-${argIndex}-${arg}`} 
                        className="lowercase" 
                        variant={activeArg === argIndex ? "default" : "muted"}
                    >
                        {arg.replaceAll("_", " ")}
                    </Badge>
                ))}
            </div>
        </button>
    )
}
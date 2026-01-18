import { useEffect, useRef } from "react";
import { MessageCircleIcon } from "lucide-react";

interface Props {
    value: string;
    forceFocus?: boolean;
    onValueChange: (value: string) => void;
    onSubmit: (value: string) => void;
    history: string[];
    historyIndex: number | null;
    setHistoryIndex: (index: number | null) => void;
}

export const ChatInput = ({ value, forceFocus = false, onValueChange, onSubmit, history, historyIndex, setHistoryIndex }: Props) => {
    const ref = useRef<HTMLInputElement>(null);

    useEffect(() => {
        if (forceFocus && ref.current) {
            ref.current.focus();
        }
    }, [forceFocus]);

    const onKeyDown = (e: React.KeyboardEvent<HTMLInputElement>) => {
        if (e.key === "Enter") {
            onSubmit(value);
            onValueChange("");
            setHistoryIndex(null);
        }

        if (e.key === "Tab") {
            e.preventDefault();
        }

        if (e.key === "ArrowUp") {
            e.preventDefault();
            if (history.length === 0) return;

            const nextIndex = historyIndex === null ? history.length - 1 : Math.max(0, historyIndex - 1);
            onValueChange(history[nextIndex]);
            setHistoryIndex(nextIndex);
        }

        if (e.key === "ArrowDown") {
            e.preventDefault();
            if (history.length === 0 || historyIndex === null) return;

            const nextIndex = historyIndex + 1;
            if (nextIndex >= history.length) {
                onValueChange("");
                setHistoryIndex(null);
            } else {
                onValueChange(history[nextIndex]);
                setHistoryIndex(nextIndex);
            }
        }
    }

    const onBlur = (e: React.FocusEvent<HTMLInputElement>) => {
        if (forceFocus && ref.current && !e.relatedTarget) {
            setTimeout(() => {
                if (ref.current) ref.current.focus();
            }, 0);
        }
    }

    return (
        <div className="relative w-full">
            <MessageCircleIcon className="size-4 text-muted-foreground absolute top-1/2 -translate-y-1/2 left-4" />
            <input
                ref={ref}
                value={value}
                onChange={e => onValueChange(e.target.value)}
                onKeyDown={onKeyDown}
                onBlur={onBlur}
                placeholder="Napisz coś..."
                className="p-4 rounded-[10px] bg-[hsla(0_0%_9%_/_0.9)] border-2 border-neutral-600 shadow h-10 w-full text-xs ps-9 outline-none"
            />
        </div>
    )
}
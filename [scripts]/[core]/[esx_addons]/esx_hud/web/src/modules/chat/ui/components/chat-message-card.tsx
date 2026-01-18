import { memo, useEffect, useRef } from "react";
import { Box } from "@/components/box";
import { LuaIcon } from "@/components/lua-icon";
import { useSanitizeHtml } from "@/hooks/use-sanitize-html";
import { formatHTMLToColor } from "@/lib/utils";
import type { ChatMessage } from "@/modules/chat/types/chat-message";

export const ChatMessageCard = memo(({
    title,
    icon,
    tags,
    html,
    text,
    timestamp,
    themeColor,
}: ChatMessage) => {
    const ref = useRef<HTMLDivElement>(null);

    const date = new Date((timestamp && !isNaN(timestamp) ? timestamp : Date.now() / 1000) * 1000);
    
    const validDate = isNaN(date.getTime()) ? new Date() : date;

    const sanitizedHtmlRaw = html ? formatHTMLToColor(html) : null;
    const sanitizedHtml = useSanitizeHtml(sanitizedHtmlRaw || "");

    useEffect(() => ref.current?.scrollIntoView({ behavior: "smooth" }), []);

    return (
        <Box
            ref={ref}
            className="p-4 rounded-xl flex flex-col gap-y-2"
            style={{
                "--c": `hsl(${themeColor})`,
                backgroundImage: `linear-gradient(to top, hsla(${themeColor} / 0.1), transparent)`
            } as React.CSSProperties}
        >
            <div className="flex items-center justify-between gap-x-1.5">
                <div className="flex items-center gap-x-1">
                    {icon && (
                        <LuaIcon
                            name={icon}
                            className="size-4 text-c"
                        />
                    )}
                    <span className="font-semibold text-xs">
                        {title + " "}
                        <span className="text-c">
                            {tags?.map(tag => `[${tag}]`).join(" ")}
                        </span>
                    </span>
                </div>
                <span className="text-[10px] text-muted-foreground font-semibold">
                    {validDate.getHours()}:{validDate.getMinutes().toString().padStart(2, "0")}
                </span>
            </div>
            {sanitizedHtmlRaw && sanitizedHtml ? (
                <div
                    dangerouslySetInnerHTML={{ __html: sanitizedHtml }}
                    className="text-[10px] font-medium"
                />
            ) : (
                <span className="text-[10px] font-medium">{text}</span>
            )}
        </Box>
    )
}, (prevProps, nextProps) => {
    return prevProps.timestamp === nextProps.timestamp;
});

ChatMessageCard.displayName = 'ChatMessageCard';

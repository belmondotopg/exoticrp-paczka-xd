import { memo, useEffect, useRef } from "react";

import { formatHTMLToColor } from "@/lib/utils";
import { useSanitizeHtml } from "@/hooks/use-sanitize-html";
import { DEFAULT_NOTIFICATION_DURATION, NOTIFICATION_ICON, DEFAULT_NOTIFICATION_TITLE, NOTIFICATION_COLORS } from "@/modules/notifications/constnats";
import type { Notification } from "@/modules/notifications/types/notification";
import { Box } from "@/components/box";

export const NotificationCard = memo(({
    title,
    type = "info",
    html,
    hideHeader = false,
    duration = DEFAULT_NOTIFICATION_DURATION
}: Notification) => {
    // Safety check: ensure type is valid
    const safeType = (type && NOTIFICATION_ICON[type]) ? type : "info";
    
    title = title ?? DEFAULT_NOTIFICATION_TITLE[safeType];
    const Icon = NOTIFICATION_ICON[safeType];
    const color = NOTIFICATION_COLORS[safeType];

    if (!Icon) {
        console.error('[NotificationCard] Icon is undefined for type:', type);
        return null;
    }

    const ref = useRef<HTMLDivElement>(null);

    const sanitizedHtml = useSanitizeHtml(formatHTMLToColor(html));

    useEffect(() => {
        const animationTimeout = setTimeout(() => {
            ref.current?.classList.add("out");
        }, duration);

        return () => {
            clearTimeout(animationTimeout);
        }
    }, [ref, duration]);

    return (
        <Box
            ref={ref}
            className="flex flex-col gap-y-1.5 p-4 rounded-xl notification"
            style={{
                "--c": `hsl(${color})`,
                backgroundImage: `linear-gradient(to top, hsla(${color} / 0.075), transparent)`
            } as React.CSSProperties}
        >
            {!hideHeader && (
                <div className="flex items-center gap-x-2">
                    <div className="size-5 rounded-full bg-neutral-900 grid place-items-center relative">
                        <Icon className="text-c size-2" strokeWidth={3} />
                        <div className="size-full rounded-full border border-t-c border-neutral-900 absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 animate-spin animation-duration-[2000ms]" />
                    </div>
                    <span className="font-semibold">
                        {title}
                    </span>
                </div>
            )}
            <div
                className="text-xs text-[hsla(0_0%_100%_/_0.5)]"
                dangerouslySetInnerHTML={{ __html: sanitizedHtml }}
            />
        </Box>
    )
}, (prevProps, nextProps) => {
    // Porównanie wszystkich kluczowych props
    return prevProps.id === nextProps.id && 
           prevProps.html === nextProps.html &&
           prevProps.type === nextProps.type;
});

NotificationCard.displayName = 'NotificationCard';

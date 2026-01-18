import * as React from "react";
import DOMPurify, { type Config } from "dompurify";

export const useSanitizeHtml = (html: string, config: Config = {
    ALLOWED_TAGS: ["b", "strong", "p", "span", "div", "em", "i", "br"],
    ALLOWED_ATTR: ["class", "style"]
}) => {
    const sanitizedHtml = React.useMemo(() => {
        return DOMPurify.sanitize(html, config);
    }, [html, config]);

    return sanitizedHtml;
}
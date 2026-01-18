export type ChatMessage = {
    title: string;
    icon?: string;
    tags?: string[];
    html?: string;
    text?: string;
    timestamp: number;
    themeColor: string;
}
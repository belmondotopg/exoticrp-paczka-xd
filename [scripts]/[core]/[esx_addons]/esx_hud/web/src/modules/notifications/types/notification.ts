export type NotificationType = "info" | "success" | "error";

export type Notification = {
    id?: string;
    title?: string;
    type?: NotificationType;
    html: string;
    duration?: number;
    hideHeader?: boolean;
}
import { FaInfo } from "react-icons/fa6";

import type { NotificationType } from "@/modules/notifications/types/notification";
import type { IconType } from "react-icons/lib";
import { CheckIcon, XIcon, type LucideIcon } from "lucide-react";

export const DEFAULT_NOTIFICATION_DURATION = 3000;
export const NOTIFICATION_OUT_ANIMATION_DURATION = 200;

export const DEFAULT_NOTIFICATION_TITLE: Record<NotificationType, string> = {
    info: "Powiadomienie",
    success: "Sukces",
    error: "Błąd"
};

export const NOTIFICATION_ICON: Record<NotificationType, IconType | LucideIcon> = {
    info: FaInfo,
    success: CheckIcon,
    error: XIcon
};

export const NOTIFICATION_COLORS: Record<NotificationType, string> = {
    info: "var(--primary-hsl)",
    success: "160 100% 37%",
    error: "357 96% 58%"
};
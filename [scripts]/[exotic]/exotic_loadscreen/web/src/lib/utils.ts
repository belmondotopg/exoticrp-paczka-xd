import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

declare global {
    interface Window {
        invokeNative: (method: "openUrl", url: string) => void
    }
}

export function cn(...inputs: ClassValue[]) {
    return twMerge(clsx(inputs));
}

export function openUrl (url: string) {
    if (process.env.NODE_ENV === "development") window.open(url);
    else window.invokeNative("openUrl", url);
}
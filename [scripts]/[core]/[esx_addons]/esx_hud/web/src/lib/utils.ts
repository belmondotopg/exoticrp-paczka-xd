import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

import { TEXT_COLORS } from "@/constants";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}

export const formatHTMLToColor = (value: string) => value && value.replace(/~([^h])~([^~]+)/g, (_, color: string, text: string) => `<span style="color: ${TEXT_COLORS[color] ?? '#FFFFFF'}">${text}</span>`);
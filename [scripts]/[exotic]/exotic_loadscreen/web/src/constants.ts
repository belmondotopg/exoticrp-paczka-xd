import type { KeyboardType } from "./types";

export const BACKGROUND_IMAGES = [
  "https://blog.fivemods.io/storage/2025/02/2-1-1-1.png",
  "https://blog.fivemods.io/storage/2025/04/381-1300x650.png",
  "https://blog.fivemods.io/storage/2024/12/267-1-1000x600.png",
  "https://blog.fivemods.io/storage/2025/02/IMG_20241112_034400_345-1000x600.png",
  "https://blog.fivemods.io/storage/2025/01/Grand-Theft-Auto-V-Screenshot-2024.10.29-20.06.47.37-1000x600.png",
  "https://blog.fivemods.io/storage/2024/01/cover-4-1000x600.webp"
] as const;

export const DEFAULT_SONG_URLS: string[] = [
  "https://www.youtube.com/watch?v=zuv8vmR8qt4" // underway ctpher
] as const;

export const LOCAL_YT_DATA_API_ENDPOINT = "http://5.83.147.47:2137/youtube" as const;

export const KEYBOARD_DATA: KeyboardType = {
  "F1": ["Radial Menu"],
  "F2": ["Ekwipunek"],
  "F3": ["Menu Animacji"],
  "F5": ["Zmiana Odległości Mówienia"],
  "T": ["Chat"],
  "DEL": ["Tablety Frakcyjne"]
} as const;
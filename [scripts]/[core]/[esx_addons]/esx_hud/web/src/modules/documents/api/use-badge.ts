import { useNuiData } from "@yankes/fivem-react/hooks";
import type { Badge } from "../types/badge";

const MOCK_DATA: Badge = {
    firstName: "Marcus",
    lastName: "Rainwater",
    mugshot: "https://s3-gallery.int-cdn.lcpdfrusercontent.com/monthly_2022_10/small.218_20220724074023_1.png.86bea209e701d2ede89070ff7cf23b2e.png",
    ssn: 55121,
    badge: "FCZ-513",
    grade: "Sierżant II",
    fraction: "Los Santos Police Department"
}

export const useBadge = () => {
    return useNuiData<Badge | null>("badge", process.env.NODE_ENV === "development" ? MOCK_DATA : null);
}
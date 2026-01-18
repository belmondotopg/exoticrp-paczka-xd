import { useNuiData } from "@yankes/fivem-react/hooks";
import type { HudData } from "@/modules/hud/types/hud-data";

const MOCK_DATA: HudData = {
    health: 25,
    armour: 50,
    hunger: 90,
    thirst: 40,
    oxygen: 80
}

export const useHudData = () => {
    return useNuiData<HudData | null>("hud-data", process.env.NODE_ENV === "development" ? MOCK_DATA : null);
}
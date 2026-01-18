import { useNuiData } from "@yankes/fivem-react/hooks";
import type { CarhudData } from "../types/carhud-data";

const MOCK_DATA: CarhudData = {
    kmh: 5,
    fuel: 40,
    isEngineOn: true,
    isSeatbeltOn: false,
    rpm: 1000,
    gear: 3,
    direction: "South-East",
    roadName: "Route 66",
    rotation: 359
}

export const useCarhudData = () => {
    return useNuiData<CarhudData | null>("carhud-data", process.env.NODE_ENV === "development" ? MOCK_DATA : null);
}
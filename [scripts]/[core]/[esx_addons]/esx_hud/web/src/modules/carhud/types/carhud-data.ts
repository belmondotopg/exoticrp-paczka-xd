export type GearType = 0 | 1 | 2 | 3 | 4 | 5 | 6 | "R";

export type CarhudData = {
    kmh: number;
    fuel: number;
    isEngineOn: boolean;
    isSeatbeltOn: boolean;
    rotation: number;
    rpm: number;
    gear: GearType;
    direction: string;
    roadName: string;
}
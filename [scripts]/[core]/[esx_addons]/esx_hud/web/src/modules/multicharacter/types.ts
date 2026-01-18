export type Character = {
    id: string;
    firstName: string;
    lastName: string;
    mugshot: string;
    lastLocation: string;
    bank: number;
    cash: number;
    job: string | null;
    gender: "male" | "female";
    birthDate: string;
    height: number;
}

export type MulticharacterData = {
    characters: Character[];
    maxSlots: number;
}
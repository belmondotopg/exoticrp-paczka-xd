import { useNuiData } from "@yankes/fivem-react/hooks";
import type { BusinessCard } from "../types/business-card";

const MOCK_DATA: BusinessCard = {
    firstName: "Marcus",
    lastName: "Rainwater",
    mugshot: "https://s3-gallery.int-cdn.lcpdfrusercontent.com/monthly_2022_10/small.218_20220724074023_1.png.86bea209e701d2ede89070ff7cf23b2e.png",
    ssn: 55121,
    phoneNumber: "555-555-555",
    job: "Exotic Tuners - Starszy Mechanik"
}

export const useBusinessCard = () => {
    return useNuiData<BusinessCard | null>("business-card", process.env.NODE_ENV === "development" ? MOCK_DATA : null);
}
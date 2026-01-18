import { useNuiData } from "@yankes/fivem-react/hooks";
import type { DocumentId } from "../types/document-id";

const MOCK_DATA: DocumentId = {
    firstName: "Marcus",
    lastName: "Rainwater",
    mugshot: "https://s3-gallery.int-cdn.lcpdfrusercontent.com/monthly_2022_10/small.218_20220724074023_1.png.86bea209e701d2ede89070ff7cf23b2e.png",
    ssn: 55121,
    birthDate: new Date("1990-08-08").getTime() / 1000,
    gender: "m",
    nationality: "USA",
    gunLicense: false,
    height: 184,
    drivingLicense: {
        a: false,
        b: true,
        c: false
    }
}

export const useDocumentId = () => {
    return useNuiData<DocumentId | null>("document-id", process.env.NODE_ENV === "development" ? MOCK_DATA : null);
}
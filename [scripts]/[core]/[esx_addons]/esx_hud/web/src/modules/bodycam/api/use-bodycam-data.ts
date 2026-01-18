import { useNuiData } from "@yankes/fivem-react/hooks";
import type { BodycamData } from "@/modules/bodycam/types/bodycam-data";

const MOCK_DATA: BodycamData = {
    fullName: "John Doe",
    job: "LSPD",
    jobGrade: "Seregant",
    badge: "ABC",
    gopro: false
}

export const useBodycamData = () => {
    return useNuiData<BodycamData | null>("bodycam-data", process.env.NODE_ENV === "development" ? MOCK_DATA : null);
}
import { useNuiData } from "@yankes/fivem-react/hooks";
import type { RadioData } from "@/modules/radio/types/radio-data";

const MOCK_DATA: RadioData = {
    channel: "LSPD Main Channel",
    channelNumber: 5,
    members: [
        { name: "Jonathan Clark", tag: "SGT-5907", isTalking: true },
        { name: "James Adams", tag: "DET-2479", isDead: true },
        { name: "Rachel Torres", tag: "PO-1183" },
        { name: "Ethan Brooks", tag: "SGT-6342" },
        { name: "Marcus Reed", tag: "DET-3821" },
        { name: "Samantha Hill", tag: "LT-2205" },
        { name: "Logan Price", tag: "CAP-4701" },
        { name: "Daniel Kim", tag: "PO-5568" },
    ]
}

export const useRadioData = () => {
    return useNuiData<RadioData | null>("radio-data", process.env.NODE_ENV === "development" ? MOCK_DATA : null);
}
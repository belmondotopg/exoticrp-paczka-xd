import { useNuiData } from "@yankes/fivem-react/hooks";
import type { WatermarkData } from "@/modules/watermark/types/watermark-data";

const MOCK_DATA: WatermarkData = {
    serverId: 18,
    uuid: 89
}

export const useWatermarkData = () => {
    return useNuiData<WatermarkData | null>("watermark-data", process.env.NODE_ENV === "development" ? MOCK_DATA : null);
}
import { useNuiData } from "@yankes/fivem-react/hooks";

export type VoiceDistance = 1 | 2 | 3;

type MicrophoneData = {
    isTalking: boolean;
    voiceDistance: VoiceDistance;
}

const MOCK_DATA: MicrophoneData = {
    isTalking: true,
    voiceDistance: 2
}

export const useMicrophone = () => {
    return useNuiData<MicrophoneData | null>("microphone-data", process.env.NODE_ENV === "development" ? MOCK_DATA : null);
}
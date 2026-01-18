import { LOCAL_YT_DATA_API_ENDPOINT } from "@/constants";

export function extractVideoIdFromYouTubeUrl (url: string) {
    const urlObj = new URL(url);
    return urlObj.searchParams.get("v");
}

export async function getVideoData (id: string) {
    const response = await fetch(`${LOCAL_YT_DATA_API_ENDPOINT}/videos/${id}`);
    const data = await response.json();
    
    if (response.status !== 200 || 'error' in data) {
        return { error: data.error ?? "Coś poszło nie tak" };
    }

    const parsedData = {
        embeddable: data.embeddable as boolean,
        privacyStatus: data.privacyStatus as string,
        title: data.title as string
    }

    return {
        data: parsedData
    }
}
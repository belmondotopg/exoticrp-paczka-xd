import { isEnvBrowser } from "./misc";

export async function fetchNui<T = any>(eventName: string, data?: any, mockData?: T): Promise<{success: boolean, data?: T, error?: string}> {
  try {
    const options = {
      method: 'post',
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: JSON.stringify(data),
    };

    if (isEnvBrowser() && mockData) {
      return {success: true, data: mockData};
    }

    const resourceName = (window as any).GetParentResourceName ? (window as any).GetParentResourceName() : 'nui-frame-app';

    const resp = await fetch(`https://${resourceName}/${eventName}`, options);
    
    if (!resp.ok) {
      return {success: false, error: `HTTP error! status: ${resp.status}`};
    }
    
    const respFormatted = await resp.json();
    return {success: true, data: respFormatted};
  } catch (error: any) {
    console.error('fetchNui error:', error);
    return {success: false, error: error?.message || 'Unknown error'};
  }
}

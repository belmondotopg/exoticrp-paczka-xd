import { useState, useEffect } from "react";

export const useLoadingFraction = (initialValue = process.env.NODE_ENV === 'production' ? 0 : 50) => {
    const [loadingFraction, setLoadingFraction] = useState<number>(initialValue);

    useEffect(() => {
        window.addEventListener('message', function(e) {
            if(e.data.eventName === 'loadProgress') {
                setLoadingFraction(e.data.loadFraction * 100);
            }
        });
    }, []);

    return loadingFraction;
}
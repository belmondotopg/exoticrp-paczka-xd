import { useEffect, useState } from "react";
import Outfits from "./components/Outfits";
import useNuiEvent from "./hooks/useNuiEvent";
import type Outfit from "./types/outfit";
import { debugData } from "./utils/debugData";
import { AnimatePresence } from "motion/react";
import Preview from "./components/Preview";
import { isEnvBrowser } from "./utils/misc";
import { fetchNui } from "./utils/fetchNui";

interface SetVisibleEventData {
    visible: boolean;
}

interface SetDataEventData {
    outfits: Outfit[];
    limit: number;
}

debugData([
    {
        action: "setVisible",
        data: { visible: true },
    },
    {
        action: "setData",
        data: {
            outfits: [{ id: 123, label: "Napadowy", sex: "M" }],
            limit: 5,
        },
    },
]);

function App() {
    const [show, setShow] = useState<boolean>(false);
    const [limit, setLimit] = useState<number>(0);
    const [outfits, setOutfits] = useState<Outfit[]>([]);

    useNuiEvent("setVisible", (data: SetVisibleEventData) => {
        setShow(data.visible);
    });

    useNuiEvent("setData", (data: SetDataEventData) => {
        setOutfits(data.outfits || []);
        setLimit(data.limit || 0);
    });

    useEffect(() => {
        if (!show) return;

        const keyHandler = (e: KeyboardEvent) => {
            if (["Escape"].includes(e.code)) {
                if (!isEnvBrowser()) fetchNui("closeUI");
                else setShow(!show);
            }
        };

        window.addEventListener("keydown", keyHandler);

        return () => window.removeEventListener("keydown", keyHandler);
    }, [show]);

    return (
        <AnimatePresence>
            {show && <Outfits outfits={outfits} limit={limit} />}
            {show && <Preview />}
        </AnimatePresence>
    );
}

export default App;
